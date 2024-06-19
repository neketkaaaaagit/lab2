----Соединение Галактики 
CREATE SEQUENCE IF NOT EXISTS public.sq_galactic
    INCREMENT 1
    START 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.sq_galactic
    OWNER TO scblife;

CREATE TABLE IF NOT EXISTS public.galactic
(
    id integer NOT NULL,
    CONSTRAINT galactic_pk PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.galactic
    OWNER to scblife;

COMMENT ON TABLE public.galactic
    IS 'Соединение Галактики';

----Сектор
CREATE SEQUENCE IF NOT EXISTS public.sq_sector
    INCREMENT 1
    START 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.sq_sector
    OWNER TO scblife;

CREATE TABLE IF NOT EXISTS public.sector
(
    id integer NOT NULL,
    coordinates character varying(100),
    light_intensity character varying(100),
    foreign_objects character varying(100),
    number_of_starry_sky_objects integer,
    number_undefined_objects integer,
    number_of_specified_objects character varying(100),
    notes character varying(100),
	galactic_id integer NOT NULL,
    CONSTRAINT sector_pk PRIMARY KEY (id),
	CONSTRAINT galactic_fk FOREIGN KEY (galactic_id)
        REFERENCES public.galactic (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.sector
    OWNER to scblife;

COMMENT ON TABLE public.sector
    IS 'Сектор';

COMMENT ON COLUMN public.sector.id
    IS 'ИД';
	
----Объекты
CREATE SEQUENCE IF NOT EXISTS public.sq_objects
    INCREMENT 1
    START 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.sq_objects
    OWNER TO scblife;

CREATE TABLE IF NOT EXISTS public.objects
(
    id integer NOT NULL,
    object varchar(100),
    type character varying(100),
    accuracy_of_determination character varying(100),
    quantity integer,
    time character varying(100),
    date date,
    note character varying(100),
	galactic_id integer NOT NULL,
    CONSTRAINT objects_pk PRIMARY KEY (id),
	CONSTRAINT galactic_fk FOREIGN KEY (galactic_id)
        REFERENCES public.galactic (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.objects
    OWNER to scblife;

COMMENT ON TABLE public.objects
    IS 'Объекты';
	
----Естественные объекты
CREATE SEQUENCE IF NOT EXISTS public.sq_natural_objects
    INCREMENT 1
    START 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.sq_natural_objects
    OWNER TO scblife;

CREATE TABLE IF NOT EXISTS public.natural_objects
(
    id integer NOT NULL,
    type character varying(100),
    galaxy character varying(100),
    accuracy integer,
    luminous_flux character varying(100),
    related_objects character varying(100),
    note character varying(100),
	galactic_id integer NOT NULL,
    CONSTRAINT natural_objects_pk PRIMARY KEY (id),
	CONSTRAINT galactic_fk FOREIGN KEY (galactic_id)
        REFERENCES public.galactic (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.natural_objects
    OWNER to scblife;

COMMENT ON TABLE public.natural_objects
    IS 'Естественные объекты';	

----Положение 
CREATE SEQUENCE IF NOT EXISTS public.sq_position
    INCREMENT 1
    START 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;

ALTER SEQUENCE public.sq_position
    OWNER TO scblife;

CREATE TABLE IF NOT EXISTS public.position
(
    id integer NOT NULL,
    earth_position character varying(100),
    sun_position character varying(100),
    moon_position character varying(100),
	galactic_id integer NOT NULL,
    CONSTRAINT position_pk PRIMARY KEY (id),
	CONSTRAINT galactic_fk FOREIGN KEY (galactic_id)
        REFERENCES public.galactic (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.position
    OWNER to scblife;

COMMENT ON TABLE public.position
    IS 'Положение';


	
-- DROP FUNCTION IF EXISTS public.not_work_trigger_ctrl();

CREATE OR REPLACE FUNCTION public.not_workin_trigger_ctrl()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 1
    VOLATILE NOT LEAKPROOF
AS $BODY$

declare
begin
	IF EXISTS (SELECT 1 
    			FROM information_schema.columns 
    			WHERE table_name='sector' AND column_name='date_update') 
	THEN
		ALTER TABLE public.sector
			ADD COLUMN date_update date;
	END IF;
	return new;
end;
$BODY$;

ALTER FUNCTION public.not_workin_trigger_ctrl()
    OWNER TO scblife;



CREATE OR REPLACE TRIGGER not_workin_trigger_ctrl_tr
    BEFORE UPDATE 
    ON public.sector
    FOR EACH ROW
    EXECUTE FUNCTION public.not_workin_trigger_ctrl();


-- DROP PROCEDURE IF EXISTS public.usp_get_data(text,text);

CREATE OR REPLACE PROCEDURE public.usp_get_data(
	IN in_table1 text,
	IN in_table2 text)
LANGUAGE 'plpgsql'
AS $$
BEGIN
	IF (in_table1 = 'galactic' AND in_table2 <> 'galactic')
	THEN
		EXECUTE 
    		format('SELECT * FROM %I t1 JOIN %I t2 ON t1.id = t2.galactic_id', 
           	in_table1, in_table2);
	ELSE
		IF (in_table2 = 'galactic' AND in_table1 <> 'galactic')
		THEN
			EXECUTE 
    			format('SELECT * FROM %I t1 JOIN %I t2 ON t1.galactic_id = t2.id', 
           		in_table1, in_table2);	
		ELSE
			 EXECUTE 
    			format('SELECT * FROM %I t1 JOIN %I t2 ON t1.galactic_id = t2.galactic_id', 
           		in_table1, in_table2);
		END IF;
	END IF;

   
END;
$$;
ALTER PROCEDURE public.usp_get_data(text, text)
    OWNER TO scblife;