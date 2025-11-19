# Monorepo

A modern full-stack monorepo template built with TypeScript, featuring Firebase backend, Next.js and Vite applications, and shared packages for consistent development across the entire stack.

## 🏗️ Project Structure

This monorepo is organized into two main directories:

```
monorepo/
├── apps/              # Application projects
│   ├── backend/       # Firebase Functions backend
│   ├── web/           # Next.js web application
│   └── web-app/       # Vite + React web application
└── packages/          # Shared packages
    ├── eslint-config/ # Shared ESLint configurations
    ├── types/         # Shared TypeScript types and schemas
    ├── typescript-config/ # Shared TypeScript configurations
    └── ui/            # Shared React UI components
```

### Applications (`apps/`)

#### `backend/` - Firebase Functions Backend
- **Tech Stack**: Node.js 22, TypeScript, Firebase Functions
- **Purpose**: Serverless backend with Firebase Functions
- **Features**: 
  - Firebase Functions for serverless API endpoints
  - Firestore database integration
  - Firebase Storage rules
  - Firebase Authentication
  - Local emulator support for development
  - Automated deployment preparation script

#### `web/` - Next.js Application
- **Tech Stack**: Next.js 16, React 19, TypeScript
- **Purpose**: Server-side rendered web application
- **Features**:
  - App Router (Next.js 14+)
  - Tailwind CSS v4 for styling
  - Shared UI components from `@monorepo/ui`
  - Shared types from `@monorepo/types`

#### `web-app/` - Vite Application
- **Tech Stack**: Vite 7, React 19, TypeScript
- **Purpose**: Fast, lightweight single-page application
- **Features**:
  - Lightning-fast HMR with Vite
  - React with SWC for optimal performance
  - Tailwind CSS v4 for styling
  - Shared UI components from `@monorepo/ui`
  - Shared types from `@monorepo/types`

### Packages (`packages/`)

#### `eslint-config/` - Shared ESLint Configuration
- **Purpose**: Centralized linting rules for consistency across all projects
- **Exports**:
  - `@monorepo/eslint-config/base` - Base ESLint config
  - `@monorepo/eslint-config/react-internal` - React-specific rules
  - `@monorepo/eslint-config/vite-react` - Vite + React configuration
  - `@monorepo/eslint-config/nextjs` - Next.js-specific rules

#### `types/` - Shared TypeScript Types
- **Purpose**: Centralized type definitions and Zod schemas
- **Features**:
  - Shared TypeScript interfaces and types
  - Zod schemas for runtime validation
  - Used by both frontend and backend for type safety

#### `typescript-config/` - Shared TypeScript Configuration
- **Purpose**: Centralized TypeScript compiler configurations
- **Exports**:
  - `base.json` - Base TypeScript config
  - `nextjs.json` - Next.js-specific config
  - `react-library.json` - React library config
  - `vite-node.json` - Vite Node config
  - `vite-react.json` - Vite + React config

#### `ui/` - Shared UI Components
- **Purpose**: Reusable React components shared across applications
- **Features**:
  - Built with Radix UI primitives
  - Styled with Tailwind CSS v4
  - TypeScript support
  - Includes common components (Button, Spinner, etc.)
  - Theme support with `next-themes`

## 🔗 Shared Dependencies

This monorepo uses **pnpm workspaces** and **Turborepo** for efficient dependency management and build orchestration.

### Workspace Dependencies

All packages use `workspace:*` protocol to reference internal packages:

```json
{
  "dependencies": {
    "@monorepo/types": "workspace:*",
    "@monorepo/ui": "workspace:*"
  },
  "devDependencies": {
    "@monorepo/eslint-config": "workspace:*",
    "@monorepo/typescript-config": "workspace:*"
  }
}
```

### Key Shared Dependencies

- **TypeScript 5.9.3**: Consistent across all projects
- **React 19.2.0**: Used by all frontend applications
- **Tailwind CSS 4.1.17**: Unified styling system
- **ESLint 9**: Consistent code quality
- **Turbo 2.6.1**: Build system orchestration

## 🚀 Getting Started

### Prerequisites

- **Node.js**: >= 20 (Node 22 recommended)
- **pnpm**: 10.22.0 (specified in `packageManager` field)

### Installation

```bash
# Install pnpm if you haven't already
npm install -g pnpm@10.22.0

# Install all dependencies
pnpm install
```

### Development

```bash
# Run all apps in development mode
pnpm dev

# Run specific app
pnpm --filter backend dev
pnpm --filter web dev
pnpm --filter web-app dev

# Build all packages and apps
pnpm build

# Lint all projects
pnpm lint

# Format code
pnpm format
```

## 🔧 Configuration

### Customizing for Your Project

To customize this monorepo for your own project, you can search and replace `@monorepo` or `monorepo` with your desired project name:

```bash
# Example: Replace with your project name
find . -type f -name "*.json" -o -name "*.ts" -o -name "*.tsx" | xargs sed -i '' 's/@monorepo/@yourproject/g'
find . -type f -name "*.json" | xargs sed -i '' 's/"monorepo"/"yourproject"/g'
```

**Note**: Be careful with this replacement and review changes before committing. You may want to exclude certain files or directories.

### Firebase Backend Setup

#### Required: Set Your Firebase Project ID

Before deploying or running the backend, you **must** configure your Firebase project:

1. Navigate to `apps/backend/firebase.json`
2. Add your Firebase project configuration at the top of the file:

```json
{
  "projects": {
    "default": "your-firebase-project-id"
  },
  "firestore": {
    ...
  }
}
```

Or create a `.firebaserc` file in `apps/backend/`:

```json
{
  "projects": {
    "default": "your-firebase-project-id"
  }
}
```

You can find your Firebase project ID in the [Firebase Console](https://console.firebase.google.com/).

#### Backend Development

```bash
cd apps/backend

# Run with Firebase emulators
pnpm dev

# Build only
pnpm build

# Deploy to Firebase
pnpm deploy
```

#### Important: Deployment Recovery

The backend uses an automated deployment preparation script (`prepare-deploy.sh`) that modifies `package.json` to replace workspace dependencies with packed `.tgz` files for Firebase deployment.

**If deployment fails**, you need to manually restore the original `package.json`:

```bash
cd apps/backend

# Restore from backup
cp package.json.backup package.json

# Or use git
git restore package.json
```

The `package.json.backup` file is automatically created by the `prepare-deploy.sh` script before any modifications are made.

**Why is this necessary?**

Firebase Functions doesn't support pnpm workspaces or `workspace:*` dependencies. The deployment script:
1. Backs up your original `package.json` → `package.json.backup`
2. Builds and packs workspace dependencies into `.tgz` files
3. Rewrites `package.json` to use `file:.packed-deps/*.tgz` references
4. Deploys to Firebase

If the deployment fails mid-process, the modified `package.json` remains, and you'll need to restore it manually from the backup.

## 📦 Package Management

### Adding Dependencies

```bash
# Add to root (affects all packages)
pnpm add -w <package>

# Add to specific workspace
pnpm --filter backend add <package>
pnpm --filter web add <package>

# Add workspace dependency
pnpm --filter web add @monorepo/types@workspace:*
```

### Creating New Packages

```bash
# Create new package directory
mkdir -p packages/new-package

# Add package.json with workspace dependencies
cd packages/new-package
pnpm init
```

## 🏗️ Build System (Turborepo)

This monorepo uses **Turborepo** for intelligent build caching and task orchestration. Turborepo makes your monorepo faster by caching build outputs and understanding task dependencies.

### How Turborepo Works

Turborepo automatically handles build dependencies through the `turbo.json` configuration:

1. **Dependency Graph**: Shared packages (`types`, `ui`, `eslint-config`, `typescript-config`) build first
2. **Parallel Execution**: Independent tasks run in parallel for maximum speed
3. **Smart Caching**: Build outputs are cached locally, so unchanged packages skip rebuilding

### Turborepo Commands

```bash
# Run tasks across all workspaces
turbo build          # Build all packages and apps
turbo dev            # Run all apps in development mode
turbo lint           # Lint all projects
turbo check-types    # Type-check all projects

# Run tasks with filters
turbo build --filter=backend        # Build only backend
turbo build --filter=web...         # Build web and its dependencies
turbo dev --filter=!backend         # Run dev for everything except backend

# Force rebuild (ignore cache)
turbo build --force

# Clear Turborepo cache
turbo daemon clean
```

### Understanding Task Dependencies

The `turbo.json` configuration defines task dependencies using `dependsOn`:

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],  // ^ means "dependencies must build first"
      "outputs": [".next/**", "dist/**", "lib/**"]
    }
  }
}
```

This ensures that:
- `@monorepo/types` builds before `backend`, `web`, or `web-app`
- `@monorepo/ui` builds before `web` or `web-app`
- All builds happen in the correct order automatically

### Caching

Turborepo caches build outputs for faster subsequent builds:

- **Local caching**: Enabled by default, stores in `node_modules/.cache/turbo`
- **Cache hits**: If inputs haven't changed, Turborepo restores from cache (near-instant)
- **Cache keys**: Based on file contents, environment variables, and task configuration

#### Cache Behavior

```bash
# First build - everything runs
pnpm build
# ✓ packages/types: build completed
# ✓ packages/ui: build completed
# ✓ apps/backend: build completed

# Second build - cache hits
pnpm build
# ✓ packages/types: cache hit, replaying output
# ✓ packages/ui: cache hit, replaying output
# ✓ apps/backend: cache hit, replaying output
```

#### Clearing Cache

```bash
# Clear Turborepo cache
turbo daemon clean

# Or manually delete cache directory
rm -rf node_modules/.cache/turbo
```

### Remote Caching (Optional)

For teams, you can enable remote caching with Vercel:

```bash
# Login to Vercel
npx turbo login

# Link your repository
npx turbo link
```

This allows your team to share build caches across machines and CI/CD.

### Turborepo Filters

Filters allow you to run tasks on specific packages:

```bash
# Run task on single package
turbo build --filter=backend

# Run task on package and its dependencies
turbo build --filter=web...

# Run task on package and its dependents
turbo build --filter=...@monorepo/types

# Run task on multiple packages
turbo build --filter=web --filter=web-app

# Exclude packages
turbo dev --filter=!backend
```

### Development Workflow Tips

```bash
# Develop a single app with its dependencies
turbo dev --filter=web...

# Build everything except tests
turbo build --filter=!*test*

# Run type checking in watch mode
turbo check-types --watch

# See what Turborepo will do (dry run)
turbo build --dry-run
```

### Turborepo Configuration

The `turbo.json` file at the root defines all task configurations:

- **`tasks`**: Defines available tasks and their behavior
- **`dependsOn`**: Specifies task dependencies
- **`outputs`**: Tells Turborepo what files to cache
- **`inputs`**: Specifies which files affect cache invalidation
- **`cache`**: Enable/disable caching per task
- **`persistent`**: For long-running tasks like `dev`

### Troubleshooting

**Builds are slow or not caching:**
```bash
# Check cache status
turbo build --summarize

# Force rebuild and check for issues
turbo build --force --verbose
```

**Daemon issues:**
```bash
# Restart Turborepo daemon
turbo daemon restart

# Check daemon status
turbo daemon status
```

**Cache is stale:**
```bash
# Clear cache and rebuild
turbo daemon clean
pnpm build
```

## 🧪 Testing

```bash
# Run tests for all packages (when implemented)
pnpm test

# Run tests for specific package
pnpm --filter backend test
```

## 📝 Scripts Reference

### Root Level

- `pnpm dev` - Start all apps in development mode
- `pnpm build` - Build all packages and apps
- `pnpm lint` - Lint all projects
- `pnpm format` - Format all code with Prettier

### Backend (`apps/backend`)

- `pnpm dev` - Run with Firebase emulators and watch mode
- `pnpm build` - Compile TypeScript
- `pnpm deploy` - Prepare and deploy to Firebase
- `pnpm serve` - Run Firebase emulators
- `pnpm logs` - View Firebase function logs

### Web (`apps/web`)

- `pnpm dev` - Start Next.js dev server
- `pnpm build` - Build for production
- `pnpm start` - Start production server
- `pnpm lint` - Lint Next.js app

### Web App (`apps/web-app`)

- `pnpm dev` - Start Vite dev server
- `pnpm build` - Build for production
- `pnpm preview` - Preview production build
- `pnpm lint` - Lint Vite app

## 🤝 Contributing

1. Create a new branch for your feature
2. Make your changes
3. Run `pnpm lint` and `pnpm build` to ensure everything works
4. Submit a pull request

## 📄 License

Open Source

## 🔗 Useful Links

- [Turborepo Documentation](https://turbo.build/repo/docs)
- [pnpm Workspaces](https://pnpm.io/workspaces)
- [Firebase Functions](https://firebase.google.com/docs/functions)
- [Next.js Documentation](https://nextjs.org/docs)
- [Vite Documentation](https://vitejs.dev/)
- [Tailwind CSS v4](https://tailwindcss.com/docs)
