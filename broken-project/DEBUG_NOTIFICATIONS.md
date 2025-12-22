# Debugging Teams Notifications Not Triggering

## Checklist

### 1. Verify Secret Exists
```bash
kubectl get secret argocd-notifications-secret -n argocd
kubectl get secret argocd-notifications-secret -n argocd -o yaml
```

The secret should contain:
```yaml
stringData:
  channel-workflows-url: <your-webhook-url>
```

### 2. Verify ConfigMap
```bash
kubectl get configmap argocd-notifications-cm -n argocd -o yaml
```

### 3. Check Application Status
```bash
kubectl get application teams-workflows-test -n argocd -o yaml | grep -A 20 "status:"
```

The application must have:
- `status.operationState.phase: Succeeded`
- `status.operationState.finishedAt: <timestamp>`
- `status.reconciledAt: <timestamp>` (must be >= finishedAt)
- OR `status.observedAt: <timestamp>` (must be >= finishedAt)

### 4. Check Notification Controller Logs
```bash
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-notifications-controller --tail=100
```

Look for:
- "Start processing" messages
- "Processing skipped: sync status out of date" (indicates sync status not refreshed)
- "Failed to get api" errors
- "Failed to notify recipient" errors
- "teams webhook url" log messages

### 5. Verify Controller is Running
```bash
kubectl get pods -n argocd | grep notifications
```

### 6. Check Application Annotations
```bash
kubectl get application teams-workflows-test -n argocd -o jsonpath='{.metadata.annotations}' | jq
```

Should contain:
- `notifications.argoproj.io/subscribe.on-sync-succeeded.teams: channelName`

### 7. Test Trigger Manually
Check if the trigger condition evaluates correctly:
```bash
# Get the application status
kubectl get application teams-workflows-test -n argocd -o json | jq '.status.operationState'
```

The trigger condition is:
```
app.status.operationState != nil and app.status.operationState.phase in ['Succeeded']
```

## Common Issues

### Issue 1: Secret Missing or Incorrect
**Symptom**: Logs show "no teams webhook configured for recipient channelName"
**Fix**: Create/update the secret with the correct webhook URL

### Issue 2: Sync Status Not Refreshed
**Symptom**: Logs show "Processing skipped: sync status out of date"
**Fix**: Wait for Argo CD to fully reconcile the application. The notification will be sent once `reconciledAt` or `observedAt` is updated after `finishedAt`.

### Issue 3: Trigger Condition Not Met
**Symptom**: No logs about the trigger being evaluated
**Fix**: Ensure the application has completed a sync operation with `phase: Succeeded`

### Issue 4: Service Not Registered
**Symptom**: Errors about service type not found
**Fix**: Verify the ConfigMap has `service.teams:` (not `service.teams-workflows:` if using legacy service)

## Testing

To force a notification, you can:
1. Trigger a manual sync: `argocd app sync teams-workflows-test`
2. Wait for sync to complete
3. Check logs immediately after sync completes

## Expected Log Flow

When working correctly, you should see:
1. "Start processing" for the application
2. "Trigger on-sync-succeeded result: true"
3. "Sending notification about condition 'on-sync-succeeded...' to 'teams:channelName'"
4. "teams webhook url: <url>"
5. "teams webhook response: 1"
6. "Notification channelName was sent"

