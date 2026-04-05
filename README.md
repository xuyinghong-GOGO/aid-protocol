AID Protocol
Agent Decentralized Identity Protocol
An open-source identity infrastructure for AI Agents, based on W3C DID standards.
旨在为 AI Agent 提供中立、安全、合规、可跨平台互认的去中心化身份体系。
Project Introduction / 项目简介
AID Protocol is a decentralized identity system designed specifically for AI Agents. It solves identity fragmentation, lack of accountability, and trust issues in cross-platform Agent interactions.
本项目基于 W3C DID 标准，为 AI Agent 生态提供中立、安全、合规、可扩展的底层身份基础设施，解决 AI Agent 身份混乱、跨平台互认困难、责任追溯缺失、隐私保护不足等行业痛点。
Core Vision / 核心愿景
Let every Agent have a unique, verifiable identity.
Make Agent interactions more trusted and efficient.
让每个 Agent 都拥有唯一可验证的身份，让智能体交互更可信、更高效。
Contract Architecture / 合约架构
plaintext
contracts/
├── AIDProtocol.sol              # 主协议合约
├── AgentRegister.sol            # AI Agent 注册模块
├── DIDVerify.sol                # DID 身份验证模块
├── AgentKeyManager.sol          # 密钥碎片与权限管理模块
└── interfaces/
    └── IAgentIdentity.sol       # 统一身份接口规范
Testnet Deployment / 测试网部署信息
测试网：Sepolia Test Network
主合约地址：0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B
区块链浏览器查询：
https://sepolia.etherscan.io/address/0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B
部署状态：已成功部署，源码已开源验证，可正常调用、测试
How to Use / 使用说明
连接 Sepolia 测试网
通过合约接口完成 Agent 身份注册
发起链上 DID 验证与权限查询
进行密钥分片管理与权限控制操作
Security Notice / 安全声明
This project is currently deployed on the Sepolia testnet for development and demonstration purposes only. The smart contracts have not been formally audited. Please do not use them in mainnet production environments.
本项目当前仅部署于 Sepolia 测试网，用于开发演示与功能验证。智能合约未经过专业安全审计，请勿直接用于主网生产环境。
Communication Channels / 沟通渠道
GitHub (Official & Technical)
All development, issues, PRs, and decisions happen here.
所有正式开发、需求、代码提交与决策均在此进行。
Discord (International Community)
Coming soon
WeChat (Chinese Community)
Add WeChat: yh106801662, with note "AID Contributor"
Open Source Participation Rules / 开源参与规则
Everyone is welcome to contribute, no barriers.
所有人均可自愿参与，无门槛限制。
All formal contributions must go through GitHub.
所有正式贡献均通过 GitHub 进行。
Core architecture changes require issue discussion and approval.
核心架构与重大功能需先发起 Issue 讨论并通过审核。
This project uses Apache-2.0 License.
本项目采用 Apache-2.0 开源协议。
Contributor Rewards / 贡献者回报机制
1. Credit & Recognition / 名誉认可
All contributors listed in CONTRIBUTORS.md
所有代码贡献者列入公开贡献者名单
Core contributors will be credited in whitepaper and releases
核心贡献者在白皮书与版本发布中署名
Public acknowledgment for outstanding contributors
2. Governance Rights / 社区治理权
Top contributors join Core Team and share project decisions
核心贡献者可进入核心团队，参与项目方向决策
Obtain GitHub repository maintainer permissions
获得 GitHub 仓库维护权限
Become community administrator
3. Growth & Opportunities / 成长与机会
Real experience in AI + Web3 cutting-edge project
参与 AI + Web3 前沿项目真实实践
Priority access to ecosystem and enterprise cooperation
优先获得生态合作与企业落地机会
Priority in future team building and commercialization
4. Future Value Sharing / 未来价值分配
If donations, sponsorships, or commercial income occur in the future, core contributors will share benefits according to contribution proportion under a transparent and open mechanism.
若项目未来产生捐赠、赞助或商业收入，将按照透明公开机制，依据贡献度分配给核心贡献者。
Project Leadership / 项目主导权说明
The project direction, architecture design, and core rules are controlled by the initiator to ensure alignment with the whitepaper and long-term stability.
项目方向、架构设计与核心规则由发起人统一把控，确保项目始终符合白皮书目标并长期稳定发展。
Welcome to Contribute / 欢迎参与共建
Whether you are a developer, security researcher, document writer, or ecology enthusiast, you are welcome to join us to build the next-generation AI identity infrastructure.
无论你是开发者、安全研究者、文档编写者还是生态爱好者，都欢迎加入，共同构建下一代 AI 身份基础设施。
