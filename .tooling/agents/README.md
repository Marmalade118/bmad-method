# Agent Configurations for Azure AI Foundry

This folder holds the YAML definitions for each BMAD persona and orchestrator configurations, ready for deployment to Azure AI Foundry.

Important:

- The existing YAML files may be outdated compared to the markdown specifications. Ensure each `.agent.yaml` matches the current persona and toolset details in your markdown docs.
- Azure AI Foundry uses a different schema for knowledge, personas, and prompts; update fields accordingly.
- Refer to the [Migration Guide](./migration-guide.md) for detailed steps.

Usage:

1. Update your markdown files (`bmad-agent/personas/*.md`) with the latest details.
2. Review and manually update the corresponding YAML in this folder to match Foundry schema.
3. Run the script to copy updated YAML files:

   ```powershell
   .\.tooling\scripts\generate-foundry-configs.ps1
   ```

4. Deploy to Foundry using the Azure CLI or Foundry SDK:

   ```powershell
   az ai foundry config apply --path .\.tooling\agents
   ```
