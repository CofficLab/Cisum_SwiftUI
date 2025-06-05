# 开发文档

## 架构设计 Architecture Design

### 整体架构 Overall Architecture

```bash
UI Layer (用户界面)
    ↓ 调用
Core/Service/ (业务逻辑层)
    ↓ 调用  
Core/Repository/ (数据访问层)
    ↓ 操作
Model Layer (数据模型)
    ↓ 存储
SwiftData/CoreData
```

### 层级职责 Layer Responsibilities

- **UI Layer**: 用户界面展示和交互处理
- **Service Layer**: 业务逻辑封装、事务管理、数据验证
- **Repository Layer**: 数据访问、CRUD操作、数据库管理
- **Model Layer**: 数据模型定义和关系映射