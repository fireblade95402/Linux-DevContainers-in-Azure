# Remote-DevContainers
This shows how DevContainers can be used in VS Code for remote development with resources behind the firewall

# Options
1) Plain and simple use the SSH remote extension in VS Code. No code to show in here but worth highlighting as an option.
2) DevContainers with a VPN into the network :smile:
3) SSH extension for VS code with a twist. Remote host is Linux with Docker installed. Run DevContainer on remote host.

- [Walkthrough for 2 - Codespace with a VPN to a Vnet on Azure](Codesapce_with_a_vpn_to_vnet.md)
- [Walkthrough for 3 including setting up a VPN gateway and private vnet for the remote linux host](Remote_linux_host_with_private_vnet.md)

## Reference documentation for DevContainers and Codespaces

https://code.visualstudio.com/docs/remote/devcontainerjson-reference
https://code.visualstudio.com/docs/remote/ssh
https://code.visualstudio.com/remote/advancedcontainers/develop-remote-host
https://code.visualstudio.com/docs/remote/codespaces
...