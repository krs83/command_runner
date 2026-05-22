# command_runner

A simple and extensible command-line argument parser for Dart applications. Build CLI tools with commands, flags, and options.

## Features

- 🔧 **Commands** – organize your CLI into subcommands (like `git commit`, `git push`)
- 🚩 **Flags** – boolean options (e.g., `--verbose`, `-v`)
- 📝 **Options** – key-value arguments (e.g., `--output=file.txt`, `-o file.txt`)
- 📖 **Auto‑generated help** – built-in `HelpCommand` with verbose output
- 🔒 **Immutable views** – protects internal state with `UnmodifiableSetView`
- ⚡ **Async support** – commands can return `FutureOr`

## Quick Start

### 1. Add dependency

```yaml
dependencies:
  command_runner:
    git: https://github.com/krs83/command_runner.git
