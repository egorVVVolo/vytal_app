-- User Profiles Table
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT,
    user_goals TEXT[], -- ['Growth', 'Posture', 'HGH', 'Sleep']
    user_xp INTEGER DEFAULT 0,
    weight FLOAT,
    height FLOAT,
    age INTEGER,
    target_height FLOAT,
    is_pro BOOLEAN DEFAULT false,
    locale TEXT DEFAULT 'en',
    onboarding_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habits Table (Custom habits created by users)
CREATE TABLE public.habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subtitle TEXT,
    type TEXT NOT NULL, -- 'vitamin', 'activity', 'sleep', 'mental'
    icon TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE -- For soft deletes
);

-- Habit History (Logs of habit completions)
CREATE TABLE public.habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    habit_id TEXT NOT NULL, -- String because it can be a global preset ID or a UUID from habits table
    completed_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE, -- For soft deletes
    UNIQUE(user_id, habit_id, completed_date) -- Prevent duplicate completions for the same habit on the same day
);

-- Posture Scans Table
CREATE TABLE public.posture_scans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    overall_score FLOAT NOT NULL,
    kyphosis_score FLOAT,
    lordosis_score FLOAT,
    neck_score FLOAT,
    lost_height FLOAT,
    advice TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Workout Logs Table
CREATE TABLE public.workout_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    protocol_id TEXT NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Function to automatically update the 'updated_at' column
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply 'updated_at' triggers to tables
CREATE TRIGGER set_updated_at_users
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_habits
    BEFORE UPDATE ON public.habits
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_habit_logs
    BEFORE UPDATE ON public.habit_logs
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_posture_scans
    BEFORE UPDATE ON public.posture_scans
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_workout_logs
    BEFORE UPDATE ON public.workout_logs
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posture_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_logs ENABLE ROW LEVEL SECURITY;

-- Users Policy: Users can only read and update their own profile
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.users FOR INSERT WITH CHECK (auth.uid() = id);

-- CRITICAL: Prevent privilege escalation. Users can update their profile, but CANNOT update 'is_pro' or 'user_xp'.
CREATE POLICY "Users can update safe fields on own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Create a trigger to prevent modifying protected fields in users table
CREATE OR REPLACE FUNCTION protect_user_fields()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_pro IS DISTINCT FROM OLD.is_pro OR NEW.user_xp IS DISTINCT FROM OLD.user_xp THEN
        RAISE EXCEPTION 'Users cannot update restricted fields (is_pro, user_xp) directly.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_restricted_fields_update
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION protect_user_fields();


CREATE POLICY "Users can delete own profile" ON public.users FOR DELETE USING (auth.uid() = id);

-- Habits Policy: Users can only manage their own habits
CREATE POLICY "Users can manage own habits" ON public.habits FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Habit Logs Policy: Users can only manage their own habit logs
CREATE POLICY "Users can manage own habit logs" ON public.habit_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Posture Scans Policy: Users can only view and manage their own scans
CREATE POLICY "Users can manage own posture scans" ON public.posture_scans FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Workout Logs Policy: Users can only manage their own workout logs
CREATE POLICY "Users can manage own workout logs" ON public.workout_logs FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);


-- ==========================================
-- QUOTA CHECK FUNCTION (Workouts)
-- ==========================================
CREATE OR REPLACE FUNCTION check_workout_quota()
RETURNS TRIGGER AS $$
DECLARE
    daily_workout_count INTEGER;
BEGIN
    -- Check the quota based on the NEW.completed_at date to support offline sync correctly
    SELECT count(*) INTO daily_workout_count
    FROM public.workout_logs
    WHERE user_id = NEW.user_id
      AND completed_at >= date_trunc('day', NEW.completed_at)
      AND completed_at < date_trunc('day', NEW.completed_at) + interval '1 day';

    IF daily_workout_count >= 3 THEN
        RAISE EXCEPTION 'Daily workout limit (3) exceeded for user % on date %', NEW.user_id, date_trunc('day', NEW.completed_at);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for Workout Quota
CREATE TRIGGER enforce_workout_quota
    BEFORE INSERT ON public.workout_logs
    FOR EACH ROW EXECUTE FUNCTION check_workout_quota();
