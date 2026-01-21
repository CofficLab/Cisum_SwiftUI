# 智能生成 Commit Message

自动分析代码更改并生成符合规范的提交信息（Conventional Commits 格式）。

## 工作流程

1. **检查 Git 状态**
   - 运行 `git status` 查看当前仓库状态
   - 识别已暂存和未暂存的更改

2. **分析代码差异**
   - 运行 `git diff --staged` 查看已暂存的更改
   - 如果没有暂存的更改，运行 `git diff` 查看未暂存的更改
   - 分析以下内容：
     - 修改的文件类型（组件、页面、样式、配置等）
     - 代码变更的性质（新增、修改、删除、重构等）
     - 影响范围和重要性

3. **查看提交历史**
   - 运行 `git log -10 --oneline` 查看最近 10 条提交
   - 了解项目的 commit message 风格和约定

4. **生成 Commit Message**
   - 基于 Conventional Commits 规范：
     ```
     <type>(<scope>): <subject>

     <body>

     <footer>
     ```
   - **Type（类型）**：
     - `feat`: 新功能
     - `fix`: 修复 bug
     - `docs`: 文档变更
     - `style`: 代码格式（不影响代码运行的变动）
     - `refactor`: 重构（既不是新增功能，也不是修复 bug）
     - `perf`: 性能优化
     - `test`: 增加测试
     - `chore`: 构建过程或辅助工具的变动
     - `revert`: 回滚之前的 commit

   - **Scope（范围）**：
     - `components`: 组件相关
     - `pages`: 页面相关
     - `api`: API 相关
     - `config`: 配置相关
     - `deps`: 依赖相关
     - `ui`: UI 相关
     - 或其他合适的模块名称

   - **Subject（主题）**：
     - 简洁描述（不超过 50 字符）
     - 不以句号结尾
     - 使用祈使句（如 "add" 而非 "added" 或 "adds"）

   - **Body（正文）**：
     - 详细描述更改内容
     - 说明 "为什么" 而非 "是什么"
     - 每行限制在 72 字符以内

   - **Footer（脚注）**：
     - 关联的 Issue
     - Breaking Changes 说明
     - 其他参考信息

5. **显示建议**
   - 展示生成的 commit message
   - 展示更改的文件列表
   - 展示代码差异摘要

6. **执行确认**
   - 询问用户是否使用生成的 commit message
   - 如果确认，执行：
     - `git add` （如果需要）
     - `git commit -m "message"`
   - 如果需要修改，允许用户编辑

## Commit Message 模板

### 简单更改
```
feat(components): add button component
```

### 中等更改
```
feat(auth): implement OAuth2 login flow

Add support for Google and GitHub OAuth2 authentication.
Users can now sign in using their existing accounts from
these providers.

- Integrate NextAuth.js
- Add OAuth callback handlers
- Update login UI with social login buttons
- Store OAuth tokens securely
```

### 复杂更改
```
feat(api): implement rate limiting for all endpoints

Add rate limiting to prevent API abuse and ensure fair usage.
Limits are set to 100 requests per 15 minutes per IP address.

- Implement Redis-based rate limiter
- Add rate limit headers to responses
- Handle rate limit exceeded errors
- Add configuration options for rate limits

Closes #123
```

### Bug 修复
```
fix(auth): resolve token expiration issue

Fix authentication failing prematurely due to incorrect
token expiration calculation. Tokens now expire at the
correct time.

This issue affected users with long-lived sessions.

Fixes #456
```

## 示例输出

```
📝 建议的 Commit Message:

feat(pages): add market search page

Implement semantic search functionality for markets with
debounced input, loading states, and error handling.

- Create /markets/search route
- Add SearchBar component with debounce
- Integrate vector search API
- Display search results with MarketCard
- Handle loading and error states

Modified files:
  + app/markets/search/page.tsx (new)
  + components/SearchBar.tsx (new)
  + components/MarketList.tsx (modified)
  + lib/api/search.ts (new)

是否使用此 commit message？(y/n/edit)
```

## 注意事项

- ✅ 始终分析实际的代码差异
- ✅ 遵循项目的现有 commit 风格
- ✅ 使用清晰、描述性的语言
- ✅ 保持 subject 简洁（< 50 字符）
- ✅ 在 body 中解释 "为什么" 而非 "是什么"
- ❌ 不要在没有用户确认的情况下执行 commit
- ❌ 不要忽略 staging area 的状态
- ❌ 不要生成过于通用的 commit message

## 相关命令

- 使用 `/plan` 在实现复杂功能前进行规划
- 使用 `/code-review` 在 commit 前审查代码
- 使用 `/test-coverage` 确保测试覆盖率足够
