# This file (c) 2015-2020 AlertAvert.com.  All rights reserved.

# CMake utility functions to be reused in projects.
#
# Include in top-level CMakeLists.txt as follows:
#
#   include(${PATH_TO}/commons.cmake)
#
# See also: https://cmake.org/cmake/help/v3.0/command/include.html

# Extracts Build No. from the current git SHA and assigns it to the variable
# named RESULT_NAME
#
# See: http://stackoverflow.com/questions/6526451/how-to-include-git-commit-number-into-a-c-executable
function(get_build_id RESULT_NAME)
    IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)
      FIND_PACKAGE(Git)
      IF(GIT_FOUND)
        EXECUTE_PROCESS(
          COMMAND ${GIT_EXECUTABLE} rev-parse --short HEAD
          WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
          OUTPUT_VARIABLE "RESULT"
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE)
      ENDIF(GIT_FOUND)
    ELSE(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)
      SET(${RESULT} 0)
    ENDIF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/.git)
    SET(${RESULT_NAME} ${RESULT} PARENT_SCOPE)
endfunction(get_build_id)


# Configures installation of shared lib, headers.
#
function(config_install INSTALL_DIR INSTALL_RESULT)

  if(DEFINED INSTALL_DIR)
      # Generated configuration file, containing version and build number.
      install(FILES ${PROJECT_BINARY_DIR}/version.h DESTINATION
              "${INSTALL_DIR}/include/${PROJECT_NAME}")

      # Install Library headers.
      install(DIRECTORY ${INCLUDE_DIR}/ DESTINATION ${INSTALL_DIR}/include/${PROJECT_NAME}
              FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")
      message("Installing library headers from ${PROJECT_BINARY_DIR}/include to ${INSTALL_DIR}/include/${PROJECT_NAME}")

      # Install all dependencies
      install(DIRECTORY ${PROJECT_BINARY_DIR}/include DESTINATION
              ${INSTALL_DIR}
              FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp")
      message("Installing dependencies headers from ${PROJECT_BINARY_DIR}/include to ${INSTALL_DIR}/include")

      install(DIRECTORY ${PROJECT_BINARY_DIR}/lib DESTINATION
              ${INSTALL_DIR}
              FILES_MATCHING PATTERN "*.so*" PATTERN "*.dylib*")
      message("Installing shared libraries from ${PROJECT_BINARY_DIR}/lib to ${INSTALL_DIR}/lib")

      set(${INSTALL_RESULT} "done" PARENT_SCOPE)
  else()
      message(WARNING "INSTALL_DIR is not defined, files will not be installed."
                      " Use -DINSTALL_DIR=/path/to/install to enable")
  endif()

endfunction(config_install)
