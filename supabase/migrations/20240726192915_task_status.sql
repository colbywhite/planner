ALTER TABLE public.tasks
    ADD COLUMN completed boolean NOT NULL DEFAULT false;

CREATE OR REPLACE FUNCTION toggle_task_completion(task_id uuid)
    RETURNS public.tasks AS
$BODY$
DECLARE
    updated_task public.tasks%ROWTYPE;
BEGIN
    UPDATE public.tasks
    SET completed = NOT completed
    WHERE id = task_id
    RETURNING * INTO updated_task;

    RETURN updated_task;
END;
$BODY$
    LANGUAGE plpgsql;

