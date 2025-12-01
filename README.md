# Peaceful Robot Agents

This project builds AI agents using Microsoft's Semantic Kernel framework to advance the development of peaceful robots and ethical AI systems on peacefulrobot.com.

## Core Focus

The agents work on the fundamental mission of peacefulrobot.com: designing, building, and promoting robots and AI systems that prioritize peace, ethics, and human well-being. They perform research, design, development, and educational tasks to push forward the field of peaceful robotics.

## Agent Tasks

The agents are designed to actively contribute to peaceful robot development while the user is at work. Tasks include:

- **Research & Ideation**: Generate new ideas for peaceful robot designs, ethical AI implementations, and innovative applications.
- **Design & Prototyping**: Create specifications, blueprints, and prototypes for peaceful robot systems.
- **Code Development**: Write software for robot control, AI algorithms, and simulation environments.
- **Content Creation**: Produce educational materials, technical documentation, and promotional content about peaceful robotics.
- **Testing & Validation**: Develop test scenarios and validation methods for ensuring robot safety and ethical behavior.
- **A2A Communication**: Agents coordinate via Agent-to-Agent protocol for task delegation and response handling.
- **Recursive Development**: Break down complex robot projects into sub-tasks, spawning specialized sub-agents for components like hardware design, software integration, or ethical analysis.

## Recursive Behavior

The agents implement recursive behavior by:
- Breaking down complex tasks into smaller sub-tasks.
- Spawning child agents to handle specific sub-tasks.
- Iteratively refining outputs based on feedback loops.

## Setup

1. Install dependencies: `pip install -r requirements.txt`
2. Install and start Ollama (free local LLM service): https://ollama.ai
3. Pull a model: `ollama pull llama3.2` (or your preferred free model)
4. Run the main script: `python src/main.py`

**Note:** The system now uses Ollama for completely free, local LLM inference instead of external APIs.

**Future Enhancements:**
- **MCP Integration**: Planned Model Context Protocol support for standardized tool access across agents

## Project Structure

- `src/main.py`: Main entry point for kernel setup
- `src/agents/`: Directory for agent implementations
- `src/communication/`: A2A protocol for inter-agent communication
- `requirements.txt`: Python dependencies
- `.env`: Environment variables
- `LANGUAGE_COMPARISON.md`: Analysis of Python vs C# for dual-stack development
- `SECURITY.md`: NIST SSDF security policy and compliance

## Dual-Stack Architecture

This project implements a dual-stack approach:
- **Free Software Stack**: Python implementation (current) for research and community development
- **Enterprise Stack**: Planned C# implementation for commercial deployments

See `LANGUAGE_COMPARISON.md` for detailed comparison and viability analysis.
