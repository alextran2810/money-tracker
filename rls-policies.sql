-- Row Level Security (RLS) Policies for Money Tracker Application
-- This ensures users can only access their own data

-- Enable RLS on all tables
ALTER TABLE public.wages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.work_expense ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reimbursements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_expense ENABLE ROW LEVEL SECURITY;

-- ==================================================
-- WAGES TABLE POLICIES
-- ==================================================

-- Policy for SELECT (users can only view their own wages)
CREATE POLICY "Users can only view their own wages" ON public.wages
    FOR SELECT USING (auth.uid() = user_id);

-- Policy for INSERT (users can only insert wages with their own user_id)
CREATE POLICY "Users can only insert their own wages" ON public.wages
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for UPDATE (users can only update their own wages)
CREATE POLICY "Users can only update their own wages" ON public.wages
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Policy for DELETE (users can only delete their own wages)
CREATE POLICY "Users can only delete their own wages" ON public.wages
    FOR DELETE USING (auth.uid() = user_id);

-- ==================================================
-- WORK_EXPENSE TABLE POLICIES
-- ==================================================

-- Policy for SELECT (users can only view their own work expenses)
CREATE POLICY "Users can only view their own work expenses" ON public.work_expense
    FOR SELECT USING (auth.uid() = user_id);

-- Policy for INSERT (users can only insert work expenses with their own user_id)
CREATE POLICY "Users can only insert their own work expenses" ON public.work_expense
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for UPDATE (users can only update their own work expenses)
CREATE POLICY "Users can only update their own work expenses" ON public.work_expense
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Policy for DELETE (users can only delete their own work expenses)
CREATE POLICY "Users can only delete their own work expenses" ON public.work_expense
    FOR DELETE USING (auth.uid() = user_id);

-- ==================================================
-- REIMBURSEMENTS TABLE POLICIES
-- ==================================================

-- Policy for SELECT (users can only view their own reimbursements)
CREATE POLICY "Users can only view their own reimbursements" ON public.reimbursements
    FOR SELECT USING (auth.uid() = user_id);

-- Policy for INSERT (users can only insert reimbursements with their own user_id)
CREATE POLICY "Users can only insert their own reimbursements" ON public.reimbursements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for UPDATE (users can only update their own reimbursements)
CREATE POLICY "Users can only update their own reimbursements" ON public.reimbursements
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Policy for DELETE (users can only delete their own reimbursements)
CREATE POLICY "Users can only delete their own reimbursements" ON public.reimbursements
    FOR DELETE USING (auth.uid() = user_id);

-- ==================================================
-- FAMILY_EXPENSE TABLE POLICIES
-- ==================================================

-- Policy for SELECT (users can only view their own family expenses)
CREATE POLICY "Users can only view their own family expenses" ON public.family_expense
    FOR SELECT USING (auth.uid() = user_id);

-- Policy for INSERT (users can only insert family expenses with their own user_id)
CREATE POLICY "Users can only insert their own family expenses" ON public.family_expense
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy for UPDATE (users can only update their own family expenses)
CREATE POLICY "Users can only update their own family expenses" ON public.family_expense
    FOR UPDATE USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Policy for DELETE (users can only delete their own family expenses)
CREATE POLICY "Users can only delete their own family expenses" ON public.family_expense
    FOR DELETE USING (auth.uid() = user_id);

-- ==================================================
-- STORAGE BUCKET POLICIES FOR RECEIPT ATTACHMENTS
-- ==================================================

-- Enable RLS on storage buckets (run this if you haven't already)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('receipts', 'receipts', false);

-- Allow authenticated users to upload files only to their own folder
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can upload their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'INSERT',
    '{authenticated}'
) ON CONFLICT DO NOTHING;

-- Allow authenticated users to view/download only their own files
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can view their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    NULL,
    'SELECT',
    '{authenticated}'
) ON CONFLICT DO NOTHING;

-- Allow authenticated users to update only their own files
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can update their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    'UPDATE',
    '{authenticated}'
) ON CONFLICT DO NOTHING;

-- Allow authenticated users to delete only their own files
INSERT INTO storage.policies (bucket_id, name, definition, check_definition, command, roles)
VALUES (
    'receipts',
    'Users can delete their own receipt files',
    'bucket_id = ''receipts'' AND auth.uid()::text = (storage.foldername(name))[1]',
    NULL,
    'DELETE',
    '{authenticated}'
) ON CONFLICT DO NOTHING;

-- ==================================================
-- VERIFICATION QUERIES
-- ==================================================

-- Run these queries to verify the policies are working correctly:

/*
-- 1. Check if RLS is enabled on all tables
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('wages', 'work_expense', 'reimbursements', 'family_expense');

-- 2. List all policies created
SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check
FROM pg_policies 
WHERE tablename IN ('wages', 'work_expense', 'reimbursements', 'family_expense')
ORDER BY tablename, cmd;

-- 3. Check storage policies
SELECT bucket_id, name, definition, command, roles
FROM storage.policies
WHERE bucket_id = 'receipts'
ORDER BY command;
*/

-- ==================================================
-- NOTES FOR IMPLEMENTATION
-- ==================================================

/*
IMPORTANT NOTES:

1. Make sure your application always includes the user_id when inserting records:
   - The user_id should be set to auth.uid() on the frontend
   - Or use database triggers to auto-populate user_id

2. For storage bucket policies to work properly:
   - Files should be organized in folders by user ID: /user_id/filename.jpg
   - Your upload function should use the user's UID as the folder name

3. Test the policies thoroughly:
   - Create test users and verify they can't see each other's data
   - Test all CRUD operations (Create, Read, Update, Delete)
   - Verify file upload/download restrictions work correctly

4. If you need to temporarily disable RLS for admin operations:
   ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
   -- Remember to re-enable it afterwards:
   ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

5. Monitor for any permission errors in your application logs
   and adjust policies as needed.
*/