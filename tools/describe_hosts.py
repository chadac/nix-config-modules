import itertools
import json
import sys

from rich.console import Console
from rich.table import Table
from rich.text import Text


hosts_json = sys.argv[1]
with open(hosts_json, "r") as f:
    hosts = json.load(f)


all_tags = sorted(list(set(itertools.chain(*[host["tags"] for host in hosts.values()]))))

console = Console()

table = Table(show_header=True, header_style="bold magenta")
table.add_column("hostname", style="bold")
table.add_column("kind")
table.add_column("system")
table.add_column("num apps")
for tag in all_tags:
    table.add_column(tag, justify="center")

check_mark = Text("✓", style="bold green")
x_mark = Text("✗", style="bold red")
for hostname, host in hosts.items():
    table.add_row(
        hostname,
        host["kind"],
        host["system"],
        str(len(host["apps"])),
        *[check_mark if tag in host["tags"] else x_mark for tag in all_tags]
    )


console.print(table)
