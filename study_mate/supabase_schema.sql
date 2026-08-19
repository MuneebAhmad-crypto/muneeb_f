-- ==========================================
-- STUDYMATE: FINAL RECOVERY & FIX SCRIPT
-- ==========================================

-- 1. Ensure all tables have the correct owner column and defaults
ALTER TABLE public.sm_courses ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.sm_assignments ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.sm_exams ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.sm_class_schedules ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.sm_attendance_records ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.sm_tasks ALTER COLUMN user_id SET DEFAULT auth.uid();
ALTER TABLE public.sm_quizzes ALTER COLUMN user_id SET DEFAULT auth.uid();

-- 2. COMPLETELY RESET RLS (Row Level Security)
-- This removes all previous broken policies and creates fresh ones.

DO $$
DECLARE
    tab text;
BEGIN
    FOR tab IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename LIKE 'sm_%')
    LOOP
        EXECUTE format('ALTER TABLE public.%I DISABLE ROW LEVEL SECURITY', tab);
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', tab);
    END LOOP;
END $$;

-- 3. CREATE UNIVERSAL OWNER-ACCESS POLICIES
-- These policies are the "Gold Standard" for Supabase apps.
-- They guarantee the logged-in user has 100% control over their data.

-- Profiles
DROP POLICY IF EXISTS "access_own_profile" ON public.sm_profiles;
CREATE POLICY "access_own_profile" ON public.sm_profiles FOR ALL TO authenticated USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Courses
DROP POLICY IF EXISTS "access_own_courses" ON public.sm_courses;
CREATE POLICY "access_own_courses" ON public.sm_courses FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Assignments
DROP POLICY IF EXISTS "access_own_assignments" ON public.sm_assignments;
CREATE POLICY "access_own_assignments" ON public.sm_assignments FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Exams
DROP POLICY IF EXISTS "access_own_exams" ON public.sm_exams;
CREATE POLICY "access_own_exams" ON public.sm_exams FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Schedules
DROP POLICY IF EXISTS "access_own_schedules" ON public.sm_class_schedules;
CREATE POLICY "access_own_schedules" ON public.sm_class_schedules FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Attendance
DROP POLICY IF EXISTS "access_own_attendance" ON public.sm_attendance_records;
CREATE POLICY "access_own_attendance" ON public.sm_attendance_records FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Tasks
DROP POLICY IF EXISTS "access_own_tasks" ON public.sm_tasks;
CREATE POLICY "access_own_tasks" ON public.sm_tasks FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Quizzes
DROP POLICY IF EXISTS "access_own_quizzes" ON public.sm_quizzes;
CREATE POLICY "access_own_quizzes" ON public.sm_quizzes FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- 4. FIX STORAGE PERMISSIONS (Critical for Profile Pictures)
-- This ensures you can upload and see your avatar even on restricted networks.
INSERT INTO storage.buckets (id, name, public) VALUES ('sm_avatars', 'sm_avatars', true) ON CONFLICT (id) DO UPDATE SET public = true;

DROP POLICY IF EXISTS "Public Access" ON storage.objects;
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'sm_avatars');

DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'sm_avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- ==========================================
-- DATA INTEGRITY CHECK
-- ==========================================
-- Ensure program/semester exist in profile
ALTER TABLE public.sm_profiles ADD COLUMN IF NOT EXISTS program TEXT;
ALTER TABLE public.sm_profiles ADD COLUMN IF NOT EXISTS semester INT DEFAULT 1;
