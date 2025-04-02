import json
import sys
import itertools

from rich.console import Console
from rich.table import Table
from rich.text import Text


apps_json = sys.argv[1]
with open(apps_json, "r") as f:
    apps = json.load(f)


check_mark = Text("✓", style="bold green")
x_mark = Text("✗", style="bold red")

all_tags = sorted(list(set(itertools.chain(*[app["tags"] for app in apps.values()]))))

console = Console()
table = Table(show_header=True, header_style="bold magenta")
table.add_column("name", style="bold")
table.add_column("description")
for tag in all_tags:
    table.add_column(tag)

for app_name, app in apps.items():
    table.add_row(
        app_name,
        app["description"],
        *[check_mark if tag in app["tags"] else
          (x_mark if tag in app["disableTags"] else "")
          for tag in all_tags]
    )

console.print(table)
