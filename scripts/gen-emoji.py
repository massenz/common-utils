#!/usr/bin/env python
#
# Uses OpenAI to generate emoji one-liner for Makefile

import argparse
import os
import sys

try:
    import openai
except ImportError:
    print("Missing required module 'openai'. Install it with:\n  pip install openai")
    exit(1)
try:
    from halo import Halo
except ImportError:
    print("Missing required module 'halo'. Install it with:\n  pip install halo")
    exit(1)


INSTRUCTIONS = """You are the Choose Emojy Assistant: given a 
one-line sentence (typically, the description of a command that will 
be executed) you equally respond with a single one-line sentence, 
enclosed by double quotes “ “, containing the following:

- a delimiter `---`
- immediately followed by an emoji that you must choose 
  based on the input sentence
- a space ` ` 
- and the original input sentence.

For example, given:
Running the compiler
you should respond with:
“--- ⚙️ Running the compiler”
"""

def get_api_key() -> str:
    key = os.getenv("OPENAI_KEY")
    if not key:
        print("Environment variable OPENAI_KEY is not set.\n"
              "Please export your OpenAI API key:\n"
              "  export OPENAI_KEY=your-api-key")
        sys.exit(1)
    return key

def get_emoji_response(input_text: str) -> str:
    client = openai.OpenAI(api_key=get_api_key())
    with Halo(text='thinking...', spinner='dots'):
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": INSTRUCTIONS},
                {"role": "user", "content": input_text}
            ]
        )
    return response.choices[0].message.content

def main():
    parser = argparse.ArgumentParser(description="Generate emoji-prefixed sentence using OpenAI Assistant 'Emoji Creator'.")
    parser.add_argument("text", help="The input sentence to process")
    args = parser.parse_args()

    output = get_emoji_response(args.text)
    print(output)     

if __name__ == "__main__":
    main()
