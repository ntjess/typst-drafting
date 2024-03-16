import subprocess
import json
from pathlib import Path
import os
from pypandoc import convert_file
import re

here = Path(__file__).resolve().parent
main_file = here / "main.typ"
content_file = here / "content.typ"
root = here.parent.parent
assets = root / "assets"
GIT_ASSETS = "https://raw.github.com/ntjess/typst-drafting/v0.2.0/assets"
use_git = os.environ.get("USE_GIT", "true").lower() == "true"

readme = (
    convert_file(content_file, "gfm", format="typst")
    .replace("\r", "")
    .replace(r"\![\]", "![]")
    .replace(r"``` example", r"```typst")
)


def replacement(match):
    replacement.counter += 1
    name = f"example-{replacement.counter}.png"
    if use_git:
        return f"{GIT_ASSETS}/{name}"
    return f"./assets/{name}"


replacement.counter = 0
readme = re.sub(r"example-\d+.png", replacement, readme)
with open(root.joinpath("README.md"), "w", encoding="utf-8") as out_file:
    out_file.write(readme)

code_blocks = json.loads(
    subprocess.check_output(
        f"typst query {main_file} <input-text> --root {root} --field value", text=True
    )
)

rel_main = main_file.relative_to(root.resolve()).as_posix()
to_compile = f"""
#import "{rel_main}": *
#show: template
#set page(
    height: auto,
    width: 6in,
    margin: (left: 1in, right: 2in, rest: 2em),
)
#set-page-properties()
"""
to_compile += "\n#pagebreak()\n".join(code_blocks)
out_file = assets / f"example-{{n}}.png"

subprocess.check_output(
    f'typst c - --root "{root}" {out_file}', input=to_compile, text=True
)
