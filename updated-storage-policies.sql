-- Updated RLS and Storage Policies for Receipt Images
-- Run this to fix receipt image display issues after RLS implementation

-- ==================================================
-- STORAGE BUCKET SETUP
-- ==================================================

-- Create the receipts bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'receipts', 
  'receipts', 
  false, 
  52428800, -- 50MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- ==================================================
-- UPDATED STORAGE POLICIES (Replace existing ones)
-- ==================================================

-- Remove old policies if they exist
DELETE FROM storage.policies WHERE bucket_id = 'receipts';

-- Allow authenticated users to upload files to their own folder
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can upload their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'INSERT',
    '{authenticated}'
);

-- Allow authenticated users to view/download only their own files
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can view their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    NULL,
    'SELECT',
    '{authenticated}'
);

-- Allow authenticated users to update only their own files
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can update their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'UPDATE',
    '{authenticated}'
);

-- Allow authenticated users to delete only their own files
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can delete their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    NULL,
    'DELETE',
    '{authenticated}'
);

-- ==================================================
-- TROUBLESHOOTING QUERIES
-- ==================================================

-- Check if the bucket exists
-- SELECT * FROM storage.buckets WHERE id = 'receipts';

-- Check storage policies
-- SELECT bucket_id, name, definition, command, roles
-- FROM storage.policies
-- WHERE bucket_id = 'receipts'
-- ORDER BY command;

-- Check existing files in bucket (if any)
-- SELECT name, bucket_id, owner, created_at
-- FROM storage.objects
-- WHERE bucket_id = 'receipts'
-- ORDER BY created_at DESC
-- LIMIT 10;

-- ==================================================
-- MIGRATION NOTES
-- ==================================================

/*
IMPORTANT: After running these policies, existing receipt images may need to be migrated:

1. OLD PATH FORMAT: shared/work/filename.jpg or shared/family/filename.jpg
2. NEW PATH FORMAT: {user_id}/work/filename.jpg or {user_id}/family/filename.jpg

If you have existing receipt images, you may need to:
1. Download them from the old paths
2. Re-upload them to the new user-specific paths
3. Update the database records with the new URLs

Alternatively, you can temporarily allow access to the old shared folder by adding this policy:

INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Temporary access to legacy shared files',
    'bucket_id = ''receipts'' AND name LIKE ''shared/%''',
    NULL,
    'SELECT',
    '{authenticated}'
);

Then gradually migrate files to the new structure.
*/