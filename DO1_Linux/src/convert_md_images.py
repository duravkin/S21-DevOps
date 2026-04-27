import re

pattern = r"!\[.*?\]\(.*?\)"
output_txt = ""

with open("README.md", "r") as f:
    for line in f:
        if re.search(pattern, line):
            print(line, end="")
            alt = re.search(r"\[(.*?)\]", line).group(1)
            url = re.search(r"\((.*?)\)", line).group(1)
            output_txt += f'<img src="{url}" alt="{alt}" width="600">\n'
        else:
            output_txt += line

with open("README.md", "w") as f:
    f.write(output_txt)
    print("\n\nEND WORK\n")