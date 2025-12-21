# Deploying to Fly.io

This guide walks you through deploying the PostgreSQL + Redis application to Fly.io.

## Prerequisites

1. **Fly.io Account**: Sign up at https://fly.io
2. **Flyctl CLI**: Install from https://fly.io/docs/getting-started/installing-flyctl/
3. **Authentication**: Run `flyctl auth login`

## Deployment Steps

### 1. Initial Setup

```bash
# Navigate to your project directory
cd /Users/ravikanth/code/demo-pg

# Login to Fly.io
flyctl auth login

# Create a new Fly.io app (if not already created)
flyctl launch
```

When prompted, you can accept the defaults or customize:
- **App name**: demo-pg
- **Region**: Choose one close to you (ord = Chicago, sfo = San Francisco, lhr = London, etc.)
- **Postgres**: No (we're using a custom setup)
- **Redis**: No (we're using a custom setup)

### 2. Configure Secrets

Set environment variables on Fly.io:

```bash
# Set PostgreSQL password
flyctl secrets set POSTGRES_PASSWORD=your-secure-password

# View secrets
flyctl secrets list
```

### 3. Create Volumes

Create volumes for persistent data storage:

```bash
# Create PostgreSQL volume (5GB)
flyctl volumes create postgres_data --region ord --size 5

# Create Redis volume (1GB)
flyctl volumes create redis_data --region ord --size 1

# List volumes
flyctl volumes list
```

**Note**: Replace `ord` with your chosen region.

### 4. Deploy to Fly.io

```bash
# Deploy the app
flyctl deploy

# Monitor deployment
flyctl logs

# Check app status
flyctl status
```

### 5. Verify Deployment

```bash
# Open the app in browser
flyctl open

# SSH into the app
flyctl ssh console

# Run commands inside container
flyctl ssh console --pty
```

## Connecting to Your Services

### From Inside Fly.io Environment

When connected via SSH:

```bash
# Connect to PostgreSQL
psql -h localhost -U postgres -d demo_db

# Connect to Redis
redis-cli -h localhost -p 6379
```

### From Your Local Machine

You can create a proxy tunnel:

```bash
# PostgreSQL tunnel
flyctl proxy 5432:5432

# In another terminal, connect:
psql -h localhost -U postgres -d demo_db
```

```bash
# Redis tunnel
flyctl proxy 6379:6379

# In another terminal, connect:
redis-cli -h localhost -p 6379
```

## Managing Your App

### View Logs

```bash
# Real-time logs
flyctl logs -f

# Filter by service
flyctl logs --process postgres
flyctl logs --process redis
```

### Scale the App

```bash
# Scale to multiple instances
flyctl scale count 2

# Check current scale
flyctl status
```

### Update Configuration

Edit `fly.toml` and redeploy:

```bash
# Make changes to fly.toml
# Then redeploy
flyctl deploy
```

### Update Secrets

```bash
# Update a secret
flyctl secrets set POSTGRES_PASSWORD=new-password

# This will trigger a redeploy
```

### View App Details

```bash
# Check configuration
flyctl info

# View machines
flyctl machines list
```

## Troubleshooting

### App won't start

```bash
# Check logs
flyctl logs

# SSH in and check manually
flyctl ssh console

# Inside container, check supervisord status
supervisorctl status
```

### Database won't initialize

```bash
# Check PostgreSQL logs
flyctl logs --process postgres

# Verify volumes are attached
flyctl volumes list
```

### Can't connect from local machine

```bash
# Test the proxy tunnel is working
flyctl proxy 5432:5432

# In another terminal
psql -h localhost -U postgres -d demo_db
```

### Need to rebuild image

```bash
# Force a rebuild and deploy
flyctl deploy --build

# Or rebuild locally first
docker build -t demo-pg:latest .
flyctl deploy
```

## Cleanup and Destruction

### Stop the App

```bash
flyctl scale count 0
```

### Destroy Everything

```bash
# Delete the app (removes volumes too)
flyctl destroy

# Confirm app deletion
flyctl apps list
```

## Advanced Configuration

### Increase Volume Size

```bash
# Create a new larger volume
flyctl volumes create postgres_data_new --region ord --size 10

# Update fly.toml to use new volume name
# Then manually migrate data if needed
```

### Multiple Regions

```bash
# Deploy to multiple regions
flyctl regions add sjc  # Add San Jose region
flyctl regions remove ord  # Remove Chicago region

# Or set replicas
flyctl scale count=2 --region ord
flyctl scale count=1 --region sjc
```

## Cost Estimation

As of 2024, Fly.io pricing includes:

- **Compute**: 3 shared-cpu-1x 256MB VMs free per month
- **Volumes**: $0.15/GB/month (prorated hourly)
- **Network**: Usually free for most use cases

For a simple setup with 1 instance and 6GB volumes:
- Approximately $1-2/month (beyond free tier)

## More Resources

- [Fly.io Documentation](https://fly.io/docs/)
- [Fly.io PostgreSQL Guide](https://fly.io/docs/reference/postgres/)
- [Fly.io Redis Guide](https://fly.io/docs/reference/redis/)
- [Fly.io CLI Reference](https://fly.io/docs/flyctl/)
