# HH - Hetzner Helper

Easily create Hetzner servers from your terminal.

## Intro

This repo contains a shell script that wraps an Ansible playbook, which allows you to easily create servers on [console.hetzner.cloud](https://console.hetzner.cloud).

For now it only supports server creation, see below for more info.

## Getting started

- Clone this repo
- Run `direnv allow` -> all dependencies are (read: should be) in the flake (assuming you have direnv installed & enabled and that you use NixOS)
- Create a file `.token` which contains an API token for the project where you want to create a VPS (the token needs read & write access - for obvious reasons)
- Run the script: `./wrapper create` & follow the steps

## Some notes

- Servers are created in Nuremberg by default (can easily be changed)
- A firewall is created automatically & applied to the server
    - Default rules: allow traffic on port 22 & all ICMP traffic
- The playbook will try to deploy an SSH key on the server, this is assumed to be `"$(whoami)"@"$(hostname)"`
    - This key needs to be present on Hetzner before running the script, the script does NOT upload SSH keys to Hetzner (yet?)
- Server types and images are those listed for Nuremberg on `console.hetzner.cloud` as of september 2023
- I am **not** responsible for your cloud bills or any incurred expenses, audit the script before running & use it at your own risk (:

***

#### Potential TODO's (@ future me):

- Ask for an SSH key, maybe even upload it
- List servers
- Remove servers
- Toggle firewall creation
- Bulk create servers?
- Fetch server types & images from API rather than hardcoding the values
- Use hcloud CLI instead of Ansible
