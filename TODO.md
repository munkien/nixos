# Todo

**Common Configuration**
1. **Simplify `common/options.nix`**: Simplify flags with custom namespaces (`my.graphical`, `my.gaming`, etc.) by either removing them or renaming them to better reflect their purpose.
2. **Consistent naming conventions**
3. Add new TODO items based on project requirements and code analysis
4. Consider using a secrets manager like Hashicorp's Vault or AWS Secrets Manager
**Hosts Configuration**
1. **Organize host-specific files**: Organize separate files for each host configuration (e.g., `hosts/pc-anders/filesystem.nix` and `hosts/server-home-1/filesystem.nix`) into a single directory with subdirectories for each host.
2. **Consolidate common settings**: Create separate files for common settings, such as storage configurations, and import them into relevant host-specific files
3. Profile-specific optimizations: Move performance tuning configurations specific to certain profiles (e.g., `desktop.nix` and `gaming.nix`) into separate files for each profile.

**Secrets Management**
[] **Simplify `agenix-rekey` usage**: Simplify the usage of `agenix-rekey` by removing unnecessary complexity
[] Consider using a secrets manager like Hashicorp's Vault or AWS Secrets Manager

**Performance Tuning**
1. **Profile-specific optimizations**: Move performance tuning configurations specific to certain profiles (e.g., `desktop.nix` and `gaming.nix`) into separate files for each profile.
2. Leverage Nix's built-in caching: Research and implement Nix's built-in caching features to optimize build processes.

**Code Style**
1. **Consistent indentation**: Adopt a consistent indentation scheme throughout the code.
2. **Simplify `mkDelayedStart` usage**: Simplify the usage of `mkDelayedStart` by removing unnecessary complexity
