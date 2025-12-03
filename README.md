# 以太坊 NFT 拍卖 DApp

一个构建在以太坊区块链上的去中心化拍卖应用程序（DApp），允许用户创建、参与和管理 ERC721 非同质化代币（NFT）的拍卖。

## 📋 项目概述

该项目是一个完整的 Web3 应用，集成了智能合约和前端界面，提供以下核心功能：

- **NFT 拍卖管理**：创建和管理 ERC721 代币的拍卖
- **竞价系统**：用户可以对拍卖进行竞价，自动退款给之前的最高出价者
- **智能合约**：安全的拍卖逻辑和代币转移机制
- **前端应用**：基于 Vue.js 的用户友好界面
- **Web3 集成**：支持 MetaMask 钱包集成

## 🏗️ 项目结构

```
auction_dapp/
├── contracts/                 # Solidity 智能合约
│   ├── AuctionRepositorty.sol    # 拍卖主合约
│   ├── DeedRepository.sol        # ERC721 代币仓库
│   ├── Migrations.sol            # 迁移合约
│   ├── ERC721/                   # ERC721 标准实现
│   │   ├── ERC721.sol
│   │   ├── ERC721Basic.sol
│   │   ├── ERC721BasicToken.sol
│   │   ├── ERC721Token.sol
│   │   ├── ERC721Holder.sol
│   │   └── ERC721Receiver.sol
│   └── utils/                    # 工具库
│       ├── AddressUtils.sol
│       └── math/
│           ├── Math.sol
│           └── SafeMath.sol
├── frontend/                  # Vue.js 前端应用
│   ├── src/
│   │   ├── components/           # Vue 组件
│   │   │   ├── Home.vue
│   │   │   └── Auction.vue
│   │   ├── models/               # JavaScript 模型层
│   │   │   ├── AuctionRepository.js
│   │   │   └── DeedRepository.js
│   │   ├── router/               # Vue Router 配置
│   │   ├── App.vue               # 主应用组件
│   │   ├── main.js               # 应用入口
│   │   └── config.js             # 配置文件
│   ├── build/                    # Webpack 构建配置
│   ├── config/                   # 环境配置
│   └── package.json              # 依赖配置
├── artifacts/                 # 编译后的合约 ABI 和字节码
├── scripts/                   # 部署脚本
├── tests/                     # 测试文件
└── remix.config.json         # Remix IDE 配置

```

## 🚀 核心功能

### 智能合约

#### AuctionRepository.sol
主要的拍卖管理合约，提供以下功能：

- **createAuction()** - 创建新拍卖
  - 需要 NFT 的所有权
  - 设置起始价格和截止时间
  
- **bidOnAuction()** - 对拍卖进行竞价
  - 自动退款给前一个出价者
  - 验证出价金额大于当前价格
  
- **finalizeAuction()** - 完成拍卖
  - 在截止时间后执行
  - NFT 转移给最高出价者
  - 资金转移给拍卖创建者
  
- **cancelAuction()** - 取消拍卖
  - 仅拍卖创建者可执行
  - 退款给最后的出价者
  - NFT 返回给创建者

#### DeedRepository.sol
ERC721 代币仓库合约，基于标准 ERC721 实现：

- **registerDeed()** - 注册新的 NFT
- **addDeedMetadata()** - 添加或更新 NFT 元数据

### 前端应用

基于 Vue.js 和 Web3.js 的响应式用户界面：

- **MetaMask 集成** - 通过 MetaMask 钱包进行账户管理和交易签名
- **首页** - 浏览所有可用拍卖
- **拍卖详情** - 查看拍卖信息、参与竞价
- **用户拍卖** - 管理用户创建的拍卖
- **实时状态更新** - 每 2 秒更新账户信息

## 📦 核心依赖

### 前端依赖

```json
{
  "vue": "^2.5.2",
  "vue-router": "^3.0.1",
  "web3": "^1.0.0-beta.31",
  "vuetify": "^0.17.6",
  "moment": "^2.22.0",
  "ethereumjs-util": "^5.1.5"
}
```

### 开发依赖

- Webpack 3
- Babel
- Vue Loader
- 以及其他构建工具

## ⚙️ 环境配置

### 网络端点 (`frontend/src/config.js`)

```javascript
JSONRPC_ENDPOINT: 'http://52.59.238.144:8545'        // RPC 端点
JSONRPC_WS_ENDPOINT: 'ws://52.59.238.144:8546'       // WebSocket 端点
SHH_ENDPOINT: 'ws://52.59.238.144:8546'              // Whisper 端点
```

### 合约地址

```javascript
DEEDREPOSITORY_ADDRESS: '0xd9145CCE52D386f254917e481eB44e9943F39138'
AUCTIONREPOSITORY_ADDRESS: '0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8'
```

### 其他配置

- **GAS_AMOUNT**: 500000 - 默认 Gas 限制
- **WHISPER_SHARED_KEY** - Whisper 协议的共享密钥

## 🛠️ 安装和运行

### 前置要求

- Node.js >= 6.0.0
- npm >= 3.0.0
- MetaMask 浏览器扩展（用于测试）
- 访问以太坊测试网络

### 安装步骤

1. **克隆项目**
```bash
git clone <repository-url>
cd auction_dapp
```

2. **安装前端依赖**
```bash
cd frontend
npm install
```

### 开发模式

```bash
# 在 frontend 目录运行
npm run dev
# 或
npm start
```

开发服务器将在 `http://localhost:8080` 启动（默认情况下）

### 生产构建

```bash
cd frontend
npm run build
```

编译后的文件将输出到 `frontend/dist` 目录

## 🔗 与以太坊交互

### 关键工作流

1. **注册 NFT**
   - 用户在 DeedRepository 中注册新的 NFT
   - 提供 Token ID 和元数据 URI

2. **创建拍卖**
   - 用户创建拍卖，关联已注册的 NFT
   - 设置起始价格和截止块号
   - NFT 被转移到 AuctionRepository 合约

3. **参与竞价**
   - 用户通过发送 ETH 和调用 `bidOnAuction()` 参与竞价
   - 系统自动退款给上一个出价者

4. **完成拍卖**
   - 在截止时间后，任何人可以调用 `finalizeAuction()`
   - NFT 转移给最高出价者
   - 资金转移给拍卖创建者

## 🔐 安全特性

- **ERC721 标准合规** - 遵循 OpenZeppelin 的 ERC721 实现
- **所有权验证** - 通过修饰符确保操作权限
- **SafeMath** - 防止整数溢出
- **自动退款机制** - 保护竞价者的资金

## 📝 智能合约事件

### AuctionRepository 事件

```solidity
event BidSuccess(address _from, uint _auctionId);          // 竞价成功
event AuctionCreated(address _owner, uint _auctionId);     // 拍卖创建
event AuctionCanceled(address _owner, uint _auctionId);    // 拍卖取消
event AuctionFinalized(address _owner, uint _auctionId);   // 拍卖完成
```

### DeedRepository 事件

```solidity
event DeedRegistered(address _by, uint256 _tokenId);       // NFT 注册
```

## 🧪 测试

测试文件位于 `tests/` 目录。可以使用 Truffle 或其他以太坊测试框架运行测试。

```bash
truffle test
```

## 📚 技术栈

| 层级 | 技术 |
|------|------|
| 智能合约 | Solidity 0.4.17 |
| 区块链 | 以太坊 |
| 前端框架 | Vue.js 2.5 |
| Web3 库 | web3.js 1.0.0-beta.31 |
| UI 框架 | Vuetify |
| 构建工具 | Webpack 3 |
| 模块化 | Babel |

## 🤝 贡献

欢迎提交 Pull Request 和 Issue。

## 👤 作者

- **iNDicat0r** - hosseini.mobin@gmail.com

## 📄 许可证

本项目开源供学习和参考使用。

## 💡 使用场景

- NFT 艺术品拍卖
- 收藏品交易平台
- 虚拟资产竞价系统
- Web3 DApp 学习示例

## ⚠️ 免责声明

本项目仅供学习和演示目的。在生产环境部署前，请进行全面的安全审计和测试。合约部署者对使用本合约代码造成的任何损失或损害承担全部责任。

## 📞 支持

如有问题或需要帮助，请提交 Issue 或联系作者。
