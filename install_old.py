#!/usr/bin/env python

import argparse
import ctypes
import json
import os
from pathlib import Path
import platform
import pprint

DEFUALT_PROFILE = "default"
DEFAULT_CONFIGURATION = "install.json"

SETTING_SOURCE_DIRECTORY = "source_directory"
SETTINGS = [SETTING_SOURCE_DIRECTORY]

ACTION_COPY = "copy"
ACTION_JUNCTION = "junction"
ACTION_SYMBOLIC_LINK = "symbolic_link"
ACTIONS = [ACTION_COPY, ACTION_JUNCTION, ACTION_SYMBOLIC_LINK]

HOOK_PRE_INSTALL = "pre_install"
HOOK_POST_INSTALL = "post_install"
HOOKS = [HOOK_PRE_INSTALL, HOOK_POST_INSTALL]


def get_script_directory():
    return os.path.dirname(__file__)


def set_working_directory(path):
    os.chdir(path)


def get_operating_system():
    return platform.system().lower()


def is_windows_administrator():
    return ctypes.windll.shell32.IsUserAnAdmin() != 0


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry", "-d", action="store_true")
    parser.add_argument("--force", "-f", action="store_true")
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--profile", "-p", default=DEFUALT_PROFILE)
    parser.add_argument("--configuration", "-c", default=DEFAULT_CONFIGURATION)
    return vars(parser.parse_args())


def parse_settings(arguments, settings):
    parsed_settings = {}
    for setting_name, setting in settings.items():
        if setting_name in SETTINGS:
            parsed_settings[setting_name] = setting
        else:
            print("TODO: Warning")

    assert SETTING_SOURCE_DIRECTORY in parsed_settings

    for argument_name, argument in arguments.items():
        parsed_settings[argument_name] = argument

    return parsed_settings


def parse_child(settings, parent, child_name):
    assert child_name in parent
    child = parent[child_name]

    assert isinstance(child, str) or isinstance(child, dict)

    if isinstance(child, str):
        return child

    if isinstance(child, dict):
        if settings["profile"] in child:
            return child[settings["profile"]]


def parse_actions(settings, actions):
    assert isinstance(actions, dict) or isinstance(actions, list)

    if isinstance(actions, dict):
        actions = [actions]

    parsed_actions = []
    for action in actions:
        kind = parse_child(settings, action, "kind")
        if not kind:
            continue

        source = parse_child(settings, action, "source")
        if not source:
            continue

        source_directory = settings["source_directory"]
        source = Path(source_directory) / Path(source)
        assert source.exists()

        destination = parse_child(settings, action, "destination")
        if not destination:
            continue

        destination = Path(destination)

        parsed_actions.append(
            {"kind": kind, "source": source, "destination": destination}
        )

    return parsed_actions


def parse_groups(settings, groups):
    assert isinstance(groups, dict)

    parsed_groups = []
    for group_name, actions in groups.items():
        parsed_actions = parse_actions(settings, actions)
        parsed_groups.append({"name": group_name, "actions": parsed_actions})

    return parsed_groups


def parse_hooks(settings, hooks):
    return None


def parse_configuration(arguments):
    configuration = Path(arguments["configuration"])
    assert configuration.is_file()

    with open(configuration, "r") as file:
        configuration = json.load(file)
        assert isinstance(configuration, dict)

        settings = None
        if "settings" in configuration:
            settings = configuration["settings"]
        parsed_settings = parse_settings(arguments, settings)

        assert "groups" in configuration
        groups = configuration["groups"]
        parsed_groups = parse_groups(parsed_settings, groups)

        hooks = None
        if "hooks" in configuration:
            hooks = configuration["hooks"]
        parsed_hooks = parse_hooks(parsed_settings, hooks)

        return parsed_settings, parsed_groups, parsed_hooks


def install(settings, groups):
    for group in groups:
        if group["actions"]:
            actions = group["actions"]
            for action in actions:
                source = action["source"]
                destination = action["destination"]
                print(f"{source} -> {destination}")


if __name__ == "__main__":
    script_directory = get_script_directory()
    set_working_directory(script_directory)

    operating_system = get_operating_system()
    if operating_system == "windows":
        if not is_windows_administrator():
            # raise SystemExit("The script must be run as a Windows administrator")
            None

    arguments = parse_arguments()

    settings, groups, hooks = parse_configuration(arguments)

    pprint.pprint(groups)

    install(settings, groups)

    # run_hook(hooks, HOOK_PRE_INSTALL)
    # install_groups(groups, arguments.profile)
    # run_hook(hooks, HOOK_POST_INSTALL)
