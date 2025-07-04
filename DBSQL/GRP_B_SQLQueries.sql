-- Tables

-- Table: public.users

-- DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS public.users
(
    user_id integer NOT NULL DEFAULT nextval('users_id_seq'::regclass),
    username character varying(50) COLLATE pg_catalog."default" NOT NULL,
    user_password text COLLATE pg_catalog."default" NOT NULL,
    first_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    last_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    email character varying(100) COLLATE pg_catalog."default",
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT users_pkey PRIMARY KEY (user_id),
    CONSTRAINT users_email_key UNIQUE (email),
    CONSTRAINT users_username_key UNIQUE (username),
    CONSTRAINT username_lowercase_only CHECK (username::text = lower(username::text))
);

-- Table: public.views

-- DROP TABLE IF EXISTS public.views;

CREATE TABLE IF NOT EXISTS public.views
(
    view_id integer NOT NULL DEFAULT nextval('views_id_seq'::regclass),
    view_name character varying(100) COLLATE pg_catalog."default" NOT NULL,
    description text COLLATE pg_catalog."default",
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT views_pkey PRIMARY KEY (view_id),
    CONSTRAINT views_name_key UNIQUE (view_name),
    CONSTRAINT no_spaces_in_view_name CHECK (POSITION((' '::text) IN (view_name)) = 0)
);

-- Table: public.roles

-- DROP TABLE IF EXISTS public.roles;

CREATE TABLE IF NOT EXISTS public.roles
(
    role_id integer NOT NULL DEFAULT nextval('roles_id_seq'::regclass),
    role_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT roles_pkey PRIMARY KEY (role_id),
    CONSTRAINT roles_name_key UNIQUE (role_name)
);

-- Table: public.user_role

-- DROP TABLE IF EXISTS public.user_role;

CREATE TABLE IF NOT EXISTS public.user_role
(
    user_role_id integer NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    CONSTRAINT user_role_pkey PRIMARY KEY (user_role_id),
    CONSTRAINT user_role_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES public.roles (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT user_role_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.users (user_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
);
-- Table: public.permissions

-- DROP TABLE IF EXISTS public.permissions;

CREATE TABLE IF NOT EXISTS public.permissions
(
    permission_id integer NOT NULL DEFAULT nextval('permissions_id_seq'::regclass),
    permission_name character varying(50) COLLATE pg_catalog."default" NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT permissions_pkey PRIMARY KEY (permission_id),
    CONSTRAINT permissions_name_key UNIQUE (permission_name),
    CONSTRAINT permissions_permission_name_check CHECK (permission_name::text = ANY (ARRAY['Read'::character varying, 'Write'::character varying, 'Delete'::character varying]::text[]))
);
-- Table: public.view_permission

-- DROP TABLE IF EXISTS public.view_permission;

CREATE TABLE IF NOT EXISTS public.view_permission
(
    view_permission_id integer NOT NULL DEFAULT nextval('view_permission_id_seq'::regclass),
    view_id integer NOT NULL,
    permission_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT view_permission_pkey PRIMARY KEY (view_permission_id),
    CONSTRAINT view_permission_view_id_permission_id_key UNIQUE (view_id, permission_id),
    CONSTRAINT view_permission_permission_id_fkey FOREIGN KEY (permission_id)
        REFERENCES public.permissions (permission_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT view_permission_view_id_fkey FOREIGN KEY (view_id)
        REFERENCES public.views (view_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);

-- Table: public.view_permission_role

-- DROP TABLE IF EXISTS public.view_permission_role;

CREATE TABLE IF NOT EXISTS public.view_permission_role
(
    view_permission_role_id integer NOT NULL DEFAULT nextval('view_permission_role_id_seq'::regclass),
    role_id integer NOT NULL,
    view_permission_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT view_permission_role_pkey PRIMARY KEY (view_permission_role_id),
    CONSTRAINT view_permission_role_role_id_view_permission_id_key UNIQUE (role_id, view_permission_id),
    CONSTRAINT view_permission_role_role_id_fkey FOREIGN KEY (role_id)
        REFERENCES public.roles (role_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT view_permission_role_view_permission_id_fkey FOREIGN KEY (view_permission_id)
        REFERENCES public.view_permission (view_permission_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE
);


--Functions--
--Get function for table users
CREATE OR REPLACE FUNCTION public.crud_get_users(
	)
    RETURNS TABLE(user_id integer, username character varying, user_password character varying, first_name character varying, last_name character varying, email character varying, created_at timestamp without time zone, updated_at timestamp without time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY
    SELECT 
        u.user_id,
        u.username::character varying,
        u.user_password::character varying,
        u.first_name::character varying,
        u.last_name::character varying,
        u.email::character varying,
        u.created_at,
        u.updated_at
    FROM public.users u;
END;
$BODY$;

--Get function for table roles
CREATE OR REPLACE FUNCTION public.crud_get_roles(
	)
    RETURNS TABLE(role_id integer, role_name character varying, created_at timestamp without time zone, updated_at timestamp without time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM public.roles;
END;
$BODY$;

--Get function for table views
CREATE OR REPLACE FUNCTION public.crud_get_views(
	)
    RETURNS TABLE(view_id integer, view_name character varying, description text, created_at timestamp without time zone, updated_at timestamp without time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
    RETURN QUERY SELECT * FROM public.views;
END;
$BODY$;


--Get function for table permissions
CREATE OR REPLACE FUNCTION public.crud_get_permissions(
	)
    RETURNS TABLE(permission_id integer, permission_name character varying, created_at timestamp without time zone, updated_at timestamp without time zone) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
    SELECT permission_id, permission_name, created_at, updated_at
    FROM public.permissions;
$BODY$;


--Delete functon for the table users 
CREATE OR REPLACE FUNCTION public.crud_delete_user(
	p_user_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.users
    WHERE user_id = p_user_id
    RETURNING 1 INTO deleted_count;

    IF deleted_count IS NOT NULL THEN
        RAISE NOTICE 'User with ID % has been deleted.', p_user_id;
    ELSE
        RAISE NOTICE 'No user found with ID %.', p_user_id;
    END IF;
END;
$BODY$;

--Delete functon for the table roles
CREATE OR REPLACE FUNCTION public.crud_delete_role(
	p_role_id integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM public.roles WHERE role_id = p_role_id) THEN
        DELETE FROM public.roles WHERE role_id = p_role_id;
        RETURN format('Role with ID %s has been deleted.', p_role_id);
    ELSE
        RETURN format('Role with ID %s does not exist.', p_role_id);
    END IF;
END;
$BODY$;


--Delete functon for the table views
CREATE OR REPLACE FUNCTION public.crud_delete_view(
	p_view_id integer)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM public.views WHERE view_id = p_view_id) THEN
        DELETE FROM public.views WHERE view_id = p_view_id;
        RETURN format('View with ID %s has been deleted.', p_view_id);
    ELSE
        RETURN format('View with ID %s does not exist.', p_view_id);
    END IF;
END;
$BODY$;


--Delete functon for the table permissions
CREATE OR REPLACE FUNCTION public.crud_delete_permission(
	p_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
BEGIN
    DELETE FROM public.permissions
    WHERE permission_id = p_id;
END;
$BODY$;



---Upsert function for users table

CREATE OR REPLACE FUNCTION public.crud_upsert_users(
	channel integer,
	stg_table character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    status text;
BEGIN
    IF channel = 1 THEN
        -- Insert new users where user_id = 0 (you can change this condition)
        EXECUTE format(
            'INSERT INTO public.users (
                username,
                user_password,
                first_name,
                last_name,
                email,
                created_at,
                updated_at
            )
            SELECT 
                username,
                user_password,
                first_name,
                last_name,
                email,
                created_at,
                updated_at
            FROM %I WHERE user_id = 0',
            stg_table
        );

        -- Update existing users based on user_id
        EXECUTE format(
            'UPDATE public.users AS tgt
             SET
                username = src.username,
                user_password = src.user_password,
                first_name = src.first_name,
                last_name = src.last_name,
                email = src.email,
                updated_at = src.updated_at
             FROM %I AS src
             WHERE tgt.user_id = src.user_id AND src.user_id <> 0',
            stg_table
        );

        status := 'saved';
        RETURN status;
    END IF;

EXCEPTION WHEN others THEN
    GET STACKED DIAGNOSTICS status = MESSAGE_TEXT;
    RETURN status;
END;
$BODY$;

CREATE TEMP TABLE users_stg AS SELECT * FROM public.users WHERE 1=0;

INSERT INTO users_stg VALUES
(0, 'newuser', 'password123', 'New', 'User', 'newuser@example.com', now(), now()),
(2, 'existinguser', 'updatedpass', 'Existing', 'User', 'existing@example.com', now(), now());

SELECT public.crud_upsert_users(1, 'users_stg');


---Upsert function for roles table
CREATE OR REPLACE FUNCTION public.crud_upset_roles(
    channel integer,
    stg_table character varying
)
RETURNS character varying
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    status text;
BEGIN
    IF channel = 1 THEN
        -- Insert new roles where role_id = 0
        EXECUTE format(
            'INSERT INTO public.roles (
                role_name,
                created_at,
                updated_at
            )
            SELECT role_name, created_at, updated_at
            FROM %I
            WHERE role_id = 0',
            stg_table
        );

        -- Update existing roles (role_id ≠ 0)
        EXECUTE format(
            'UPDATE public.roles AS tgt
             SET
                role_name = src.role_name,
                updated_at = src.updated_at
             FROM %I AS src
             WHERE tgt.role_id = src.role_id AND src.role_id <> 0',
            stg_table
        );

        status := 'saved';
        RETURN status;
    END IF;

EXCEPTION WHEN others THEN
    GET STACKED DIAGNOSTICS status = MESSAGE_TEXT;
    RETURN status;
END;
$BODY$;

CREATE TEMP TABLE roles_tmp AS SELECT * FROM public.roles WHERE 1=0;

-- Insert test data into staging table
INSERT INTO roles_tmp (role_id, role_name, created_at, updated_at)
VALUES
(0, 'New Role', now(), now()),       -- INSERT
(2, 'Updated Role', now(), now());  -- UPDATE

-- Run the function
SELECT public.crud_upsert_roles(1, 'roles_tmp');

select *from roles


---Upsert function for views table

CREATE OR REPLACE FUNCTION public.crud_upsert_views(
    channel integer,
    stg_table character varying
)
RETURNS character varying
LANGUAGE 'plpgsql'
COST 100
VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
    status text;
BEGIN
    IF channel = 1 THEN
        -- Insert new views where view_id = 0
        EXECUTE format(
            'INSERT INTO public.views (
                view_name,
                description,
                created_at,
                updated_at
            )
            SELECT view_name, description, created_at, updated_at
            FROM %I
            WHERE view_id = 0',
            stg_table
        );

        -- Update existing views (view_id ≠ 0)
        EXECUTE format(
            'UPDATE public.views AS tgt
             SET
                view_name = src.view_name,
                description = src.description,
                updated_at = src.updated_at
             FROM %I AS src
             WHERE tgt.view_id = src.view_id AND src.view_id <> 0',
            stg_table
        );

        status := 'saved';
        RETURN status;
    END IF;

EXCEPTION WHEN others THEN
    GET STACKED DIAGNOSTICS status = MESSAGE_TEXT;
    RETURN status;
END;
$BODY$;

-- Create temp staging table
CREATE TEMP TABLE views_tmp AS SELECT * FROM public.views WHERE 1=0;

INSERT INTO views_tmp (view_id, view_name, description, created_at, updated_at)
VALUES
(0, 'AnalyticsDashboard', 'Main analytics dashboard view', now(), now()),  -- INSERT
(2, 'UserMetrics', 'Updated description for user metrics view', now(), now()); -- UPDATE

-- Run the function
SELECT public.crud_upsert_views(1, 'views_tmp');

select *from views



---Upsert function for permissions table

CREATE OR REPLACE FUNCTION public.crud_upsert_permissions(
    channel integer,
    stg_table character varying
)
RETURNS character varying
LANGUAGE plpgsql
AS $$
DECLARE
    status TEXT;
BEGIN
    IF channel = 1 THEN

        -- INSERT (new rows where id = 0)
        EXECUTE '
            INSERT INTO permissions (permission_name, created_at, updated_at)
            SELECT permission_name, created_at, updated_at
            FROM ' || quote_ident(stg_table) || '
            WHERE permission_id = 0
            ON CONFLICT (permission_name)
            DO UPDATE SET updated_at = EXCLUDED.updated_at';

        -- UPDATE existing rows where permission_id ≠ 0
        EXECUTE '
            UPDATE permissions AS tgt
            SET
                permission_name = src.permission_name,
                updated_at = src.updated_at
            FROM ' || quote_ident(stg_table) || ' AS src
            WHERE src.permission_id = tgt.permission_id
              AND src.permission_id <> 0';

        status := 'saved';
        RETURN status;
    END IF;

EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS status = MESSAGE_TEXT;
    RETURN status;
END;
$$;


CREATE TEMP TABLE permissions_stg AS SELECT * FROM public.permissions WHERE 1=0;

INSERT INTO permissions_stg(permission_id, permission_name, created_at, updated_at)
VALUES
(0, 'Read', now(), now()),         -- INSERT
(2, 'Write', now(), now());        -- UPDATE

SELECT public.crud_upsert_permissions(1, 'permissions_stg');
 select *from permissions
