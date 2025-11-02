# Vision MCP Server

<Info>
  Vision MCP Server is a Z.AI capability implementation based on the Model Context Protocol (MCP), providing powerful Z.AI GLM-4.5V capabilities for MCP-compatible clients such as Claude Code and Cline, including image analysis, video understanding, and other features.
</Info>

**NPM Package**: [@z\_ai/mcp-server](https://www.npmjs.com/package/@z_ai/mcp-server) \
**Prerequisites**: [Node.js >= v22.0.0](https://nodejs.org/en/download/)

## Product Overview

<Tip>
  This Local MCP Server is an exclusive server developed by Z.AI for **GLM Coding Plan Pro or higher tiers users**, empowering your Code Agent with eyes and limitless visual understanding.
</Tip>

<Note>
  Except in Claude Code, pasting an image directly into the client cannot call this MCP Server, as the client will by default transcode the image and call the model interface directly. \
  The best practice is to place the image in a local directory and invoke the MCP Server by specifying the image name or path in the conversation. \
  For example: `What does demo.png describe?`
</Note>

## Features

<CardGroup cols={3}>
  <Card title="Image Analysis" icon="image">
    Supports intelligent analysis and content understanding of multiple image formats, giving your AI Agent visual capabilities
  </Card>

  <Card title="Video Understanding" icon="video">
    Supports visual understanding of both local and remote videos
  </Card>

  <Card title="Easy Integration" icon="plug">
    One-click installation, quick integration with Claude Code and other MCP-compatible clients
  </Card>
</CardGroup>

## Supported Tools

This server implements the Model Context Protocol and can be used with any MCP-compatible client. Currently provides the following tools:

* **`image_analysis`** - Analyze images and provide detailed descriptions, supports multiple image formats
* **`video_analysis`** - Analyze videos and provide detailed descriptions, supports multiple video formats

## Environment Variable Configuration

### Detailed Configuration

| Environment Variable | Description                | Default Value | Optional Values |
| :------------------- | :------------------------- | :------------ | :-------------- |
| `Z_AI_API_KEY`       | Z.AI API KEY               | Required      | Your API key    |
| `Z_AI_MODE`          | Service platform selection | Required      | `ZAI`           |

### Platform Configuration

<Tabs>
  <Tab title="Z.AI Platform (Z.AI)">
    Get API Key: [Z.AI Console](https://z.ai/manage-apikey/apikey-list) \\

    ```bash  theme={null}
    Z_AI_MODE=ZAI
    Z_AI_API_KEY=your_zai_api_key
    ```
  </Tab>
</Tabs>

## Installation and Usage

### Quick Start

<Steps>
  <Step title="Get API Key">
    Visit [Z.AI Open Platform](https://z.ai/manage-apikey/apikey-list) to get your API Key
  </Step>

  <Step title="Install MCP Server">
    Prerequisites: [Node.js >= v22.0.0](https://nodejs.org/en/download/) \
    Choose the appropriate installation method based on your client
  </Step>

  <Step title="Configure Environment Variables">
    Set necessary environment variables, including API Key and platform selection
  </Step>
</Steps>

### Supported Clients

<Tabs>
  <Tab title="Claude Desktop">
    **Method A: One-click Installation Command**

    Be sure to replace `your_api_key` with the API Key you obtained.

    ```bash  theme={null}
    claude mcp add -s user zai-mcp-server --env Z_AI_API_KEY=your_api_key Z_AI_MODE=ZAI -- npx -y "@z_ai/mcp-server"
    ```

    If you forgot to replace the API Key, you need to uninstall the old MCP Server before re-executing the installation command:

    ```bash  theme={null}
    claude mcp list
    claude mcp remove zai-mcp-server
    ```

    **Method B: Manual Configuration**

    Edit Claude Desktop's configuration file `.claude.json` `mcpServers` content: \
    Be sure to replace `your_api_key` with the API Key you obtained.

    ```json  theme={null}
    {
      "mcpServers": {
        "zai-mcp-server": {
          "type": "stdio",
          "command": "npx",
          "args": [
            "-y",
            "@z_ai/mcp-server"
          ],
          "env": {
            "Z_AI_API_KEY": "your_api_key",
            "Z_AI_MODE": "ZAI"
          }
        }
      }
    }
    ```
  </Tab>

  <Tab title="Cline (VS Code)">
    Add MCP server configuration in Cline extension settings:

    Be sure to replace `your_api_key` with the API Key you obtained.

    ```json  theme={null}
    {
      "mcpServers": {
        "zai-mcp-server": {
          "type": "stdio",
          "command": "npx",
          "args": [
            "-y",
            "@z_ai/mcp-server"
          ],
          "env": {
            "Z_AI_API_KEY": "your_api_key",
            "Z_AI_MODE": "ZAI"
          }
        }
      }
    }
    ```
  </Tab>

  <Tab title="OpenCode">
    Add MCP server configuration in OpenCode settings:

    Refer [OpenCode MCP Doc](https://opencode.ai/docs/mcp-servers)

    Be sure to replace `your_api_key` with the API Key you obtained.

    ```json  theme={null}
    {
        "$schema": "https://opencode.ai/config.json",
        "mcp": {
            "zai-mcp-server": {
                "type": "local",
                "command": ["npx","-y","@z_ai/mcp-server"],
                "environment": {
                    "Z_AI_API_KEY": "your_api_key",
                    "Z_AI_MODE": "ZAI"
                }
            }
        }
    }
    ```
  </Tab>

  <Tab title="Crush">
    Add MCP server configuration in Crush settings:

    Be sure to replace `your_api_key` with the API Key you obtained.

    ```json  theme={null}
    {
        "$schema": "https://charm.land/crush.json",
        "mcp": {
            "zai-mcp-server": {
                "type": "stdio",
                "command": "npx",
                "args": [
                    "-y",
                    "@z_ai/mcp-server"
                ],
                "env": {
                    "Z_AI_API_KEY": "your_api_key",
                    "Z_AI_MODE": "ZAI"
                }
            }
        }
    }
    ```
  </Tab>

  <Tab title="Roo Code, Kilo Code and Other MCP Clients">
    For Roo Code, Kilo Code and other clients that support MCP protocol, use the following general configuration:

    Be sure to replace `your_api_key` with the API Key you obtained.

    ```json  theme={null}
    {
      "mcpServers": {
        "zai-mcp-server": {
          "type": "stdio",
          "command": "npx",
          "args": [
            "-y",
            "@z_ai/mcp-server"
          ],
          "env": {
            "Z_AI_API_KEY": "your_api_key",
            "Z_AI_MODE": "ZAI"
          }
        }
      }
    }
    ```
  </Tab>
</Tabs>

## Usage Example

<Note>
  Except in Claude Code, pasting an image directly into the client cannot call this MCP Server, as the client will by default transcode the image and call the model interface directly. \
  The best practice is to place the image in a local directory and invoke the MCP Server by specifying the image name or path in the conversation. \
  For example: `What does demo.png describe?`
</Note>

Through the previous step of installing the Vision MCP server to the client, you can directly use MCP in your Coding client. \
For example, in Claude Code, inputting `hi describe this xx.png` in the conversation, the MCP Server will process the image and return the description result. (The prerequisite is that you have the image in your current directory)

![Description](https://cdn.bigmodel.cn/markdown/1760501186683image.png?attname=image.png)
![code](https://cdn.bigmodel.cn/markdown/1757345118471code.jpg?attname=code.jpg)

## Troubleshooting

Run the following command in your local terminal to verify if it can be installed locally, to troubleshoot environment, permission, and other issues:

<CodeGroup>
  ```bash Linux/macOS theme={null}
  Z_AI_API_KEY=your_api_key npx -y @z_ai/mcp-server
  ```

  ```cmd Windows Cmd theme={null}
  set Z_AI_API_KEY=your_api_key && npx -y @z_ai/mcp-server
  ```

  ```powershell Windows PowerShell theme={null}
  $env:Z_AI_API_KEY="your_api_key"; npx -y @z_ai/mcp-server
  ```
</CodeGroup>

* If installed successfully, it indicates that the environment is correct, and the issue may be with the client configuration. Please check the client's MCP configuration.
* If installation fails, please troubleshoot based on the error message. It is recommended to paste the error message to a large model for analysis and resolution.

Other common issues:

<AccordionGroup>
  <Accordion title="Connection Closed">
    **Issue：** Mcp server connection closed

    **Solutions：**

    1. Check whether Node.js 22 or a newer version is installed locally.
    2. Run `node -v` and `npx -v` to verify that the execution environment is available.
    3. Check the environment variable `Z_AI_API_KEY` is configured correctly.
  </Accordion>

  <Accordion title="Invalid API Key">
    **Issue:** Receiving invalid API Key error

    **Solutions:**

    1. Confirm the API Key is correctly copied
    2. Check if the API Key is activated
    3. Confirm the selected platform (`Z_AI_MODE`) matches the API Key
    4. Check if the API Key has sufficient balance
  </Accordion>

  <Accordion title="Connection Timeout">
    **Issue:** MCP server connection timeout

    **Solutions:**

    1. Check network connection
    2. Confirm firewall settings
    3. Increase timeout settings
  </Accordion>
</AccordionGroup>

## Related Resources

* [Model Context Protocol (MCP) Official Documentation](https://modelcontextprotocol.io/)
* [Claude Desktop MCP Configuration Guide](https://docs.anthropic.com/en/docs/claude-code/mcp)
* [Z.AI API Reference](/api-reference/introduction)
* [Vision Model Introduction](/guides/vlm/glm-4.5v)
