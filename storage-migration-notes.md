# Storage Migration Guide

## Issue
Legacy images are stored with paths like `/receipts/shared/work/filename.png` but the new RLS policies expect user-specific paths like `/receipts/{user_id}/work/filename.png`.

## Solutions Implemented

### 1. Database Path Migration (Automatic)
The app now automatically updates database records to use the new path format when it loads. This happens in the background via the `migrateLegacyImagePaths()` function.

### 2. Smart Image Loading (Automatic)
The `getAuthenticatedImageUrl()` function now:
- Tries to load images with the new user-specific path first
- Falls back to the original path if the new path fails
- Uses signed URLs for secure access

### 3. Manual Storage File Migration (If Needed)

If you need to actually move the files in Supabase storage, you can use the Supabase dashboard or API:

#### Option A: Supabase Dashboard
1. Go to Storage > receipts bucket
2. Navigate to the `shared` folder
3. Select files and move them to the appropriate user folders

#### Option B: SQL/API Script (Advanced)
```sql
-- Example of what the storage structure should look like:
-- OLD: receipts/shared/work/filename.png
-- NEW: receipts/{user_id}/work/filename.png
```

## Current Status
- ✅ Database records will be auto-migrated to new paths
- ✅ Image loading handles both old and new path formats
- ✅ New uploads use the correct user-specific paths
- ⚠️ Old files in storage may still be in `shared` folders (not breaking, but could be cleaned up)

## Testing
1. Existing receipts should now load properly
2. New receipts should upload to user-specific folders
3. Console should show successful signed URL generation