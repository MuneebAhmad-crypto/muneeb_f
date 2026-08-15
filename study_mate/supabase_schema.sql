-- ==========================================
-- STUDYMATE SUPABASE DATABASE SCHEMA
-- PREFIXED WITH 'sm_' FOR MULTI-APP PROJECTS
-- ==========================================

-- 1. PROFILES
CREATE TABLE public.sm_profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  name TEXT,
  email TEXT,
  university TEXT,
  program TEXT,
  semester INT,
  avatar_url TEXT,
  gpa DECIMAL(3,2) DEFAULT 0.0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. COURSES
CREATE TABLE public.sm_courses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  code TEXT NOT NULL,
  teacher TEXT,
  credit_hours INT DEFAULT 3,
  color TEXT,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. CLASS SCHEDULES
CREATE TABLE public.sm_class_schedules (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE CASCADE NOT NULL,
  day_of_week TEXT NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  room TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 4. ASSIGNMENTS
CREATE TABLE public.sm_assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  due_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'overdue')),
  priority TEXT DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 5. EXAMS
CREATE TABLE public.sm_exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  date_time TIMESTAMP WITH TIME ZONE NOT NULL,
  room TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 6. ATTENDANCE RECORDS
CREATE TABLE public.sm_attendance_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE CASCADE NOT NULL,
  date DATE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('present', 'absent')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 7. NOTES
CREATE TABLE public.sm_notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE SET NULL,
  title TEXT NOT NULL,
  content TEXT,
  is_favorite BOOLEAN DEFAULT false,
  folder_name TEXT DEFAULT 'General',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 8. FLASHCARD SETS
CREATE TABLE public.sm_flashcard_sets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 9. FLASHCARDS
CREATE TABLE public.sm_flashcards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  set_id UUID REFERENCES public.sm_flashcard_sets ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 10. QUIZ SETS
CREATE TABLE public.sm_quiz_sets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE CASCADE,
  title TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 11. QUIZ QUESTIONS
CREATE TABLE public.sm_quiz_questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  quiz_id UUID REFERENCES public.sm_quiz_sets ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_option_index INT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 12. STUDY SESSIONS
CREATE TABLE public.sm_study_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  course_id UUID REFERENCES public.sm_courses ON DELETE SET NULL,
  duration_minutes INT NOT NULL,
  session_type TEXT DEFAULT 'focus' CHECK (session_type IN ('focus', 'short_break', 'long_break')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 13. TASKS
CREATE TABLE public.sm_tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  due_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE public.sm_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_class_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_flashcard_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_quiz_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_study_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sm_tasks ENABLE ROW LEVEL SECURITY;

-- POLICIES

CREATE POLICY "Manage own Profile" ON public.sm_profiles FOR ALL USING (auth.uid() = id);
CREATE POLICY "Manage own Courses" ON public.sm_courses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Schedules" ON public.sm_class_schedules FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Assignments" ON public.sm_assignments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Exams" ON public.sm_exams FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Attendance" ON public.sm_attendance_records FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Notes" ON public.sm_notes FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Flashcard Sets" ON public.sm_flashcard_sets FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Flashcards" ON public.sm_flashcards FOR ALL USING (
  EXISTS (SELECT 1 FROM public.sm_flashcard_sets WHERE id = sm_flashcards.set_id AND user_id = auth.uid())
);
CREATE POLICY "Manage own Quiz Sets" ON public.sm_quiz_sets FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Quiz Questions" ON public.sm_quiz_questions FOR ALL USING (
  EXISTS (SELECT 1 FROM public.sm_quiz_sets WHERE id = sm_quiz_questions.quiz_id AND user_id = auth.uid())
);
CREATE POLICY "Manage own Study Sessions" ON public.sm_study_sessions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Manage own Tasks" ON public.sm_tasks FOR ALL USING (auth.uid() = user_id);

-- ==========================================
-- TRIGGERS & FUNCTIONS
-- ==========================================

CREATE OR REPLACE FUNCTION public.sm_handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.sm_profiles (id, name, email, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'name', new.email, new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created_sm
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.sm_handle_new_user();

CREATE OR REPLACE FUNCTION public.sm_handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_sm_profiles_updated_at BEFORE UPDATE ON public.sm_profiles FOR EACH ROW EXECUTE FUNCTION public.sm_handle_updated_at();
CREATE TRIGGER update_sm_notes_updated_at BEFORE UPDATE ON public.sm_notes FOR EACH ROW EXECUTE FUNCTION public.sm_handle_updated_at();
