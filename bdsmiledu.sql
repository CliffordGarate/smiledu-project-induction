--
-- PostgreSQL database dump
--

-- Dumped from database version 12.5
-- Dumped by pg_dump version 12.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: actualizarestadomovimiento(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizarestadomovimiento(idmovimiento integer, estadomov character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
 flagTrue integer :=1;
begin
	update movimiento set estado = estadoMov,fecha_pago = current_date
	where id_movimiento = idMovimiento;
	return flagTrue;
end;
$$;


ALTER FUNCTION public.actualizarestadomovimiento(idmovimiento integer, estadomov character varying) OWNER TO postgres;

--
-- Name: actualizarestadomovimiento(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.actualizarestadomovimiento(idmovimiento integer, estadomov character varying, iddetallecronograma integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
 flagTrue integer :=1;
begin
	update movimiento set estado = estadoMov where id_movimiento = idMovimiento;
	update detalle_cronograma set fecha_pago = current_date 
	where id_detalle_cronograma =idDetalleCronograma;
	return flagTrue;
end;
$$;


ALTER FUNCTION public.actualizarestadomovimiento(idmovimiento integer, estadomov character varying, iddetallecronograma integer) OWNER TO postgres;

--
-- Name: listarestudiantes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.listarestudiantes() RETURNS TABLE(id_persona integer, nom_persona character varying, ape_pate_pers character varying, ape_mate_pers character varying, edad character varying, foto_ruta text, id_grado integer)
    LANGUAGE plpgsql
    AS $$
BEGIN        
  FOR id_persona,
	nom_persona,
	ape_pate_pers,
	ape_mate_pers,
	edad,
	foto_ruta,
	id_grado IN 
     select 
	persona.id_persona,
	persona.nom_persona,
	persona.ape_pate_pers,
	persona.ape_mate_pers,
	obtenerEdadEstudiante(current_date,persona.fecha_naci) as edad,
	persona.foto_ruta,
	persona.id_grado
	from persona
  LOOP
    RETURN NEXT;
  END LOOP;
  RETURN;
END;
$$;


ALTER FUNCTION public.listarestudiantes() OWNER TO postgres;

--
-- Name: listarmovimientosestudiante(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.listarmovimientosestudiante(idpersona integer) RETURNS TABLE(id_movimiento integer, tipo_movimiento character varying, desc_pension character varying, monto numeric, estado character varying, fecha_pago date, id_persona integer, id_detalle_cronograma integer, fecha_venci date)
    LANGUAGE plpgsql
    AS $$
BEGIN        
  FOR id_movimiento,tipo_movimiento, desc_pension, monto,estado,fecha_pago,id_persona,
  id_detalle_cronograma,fecha_venci IN 
     select movimiento.id_movimiento, movimiento.tipo_movimiento, detalle_cronograma.desc_pension,
	 movimiento.monto, movimiento.estado, movimiento.fecha_pago, movimiento.id_persona,
	 movimiento.id_detalle_cronograma, detalle_cronograma.fecha_venci from movimiento
	 inner join detalle_cronograma on movimiento.id_detalle_cronograma = detalle_cronograma.id_detalle_cronograma 
	 where movimiento.id_persona = idPersona
  LOOP
    RETURN NEXT;
  END LOOP;
  RETURN;
END;
$$;


ALTER FUNCTION public.listarmovimientosestudiante(idpersona integer) OWNER TO postgres;

--
-- Name: obteneredadestudiante(date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obteneredadestudiante(fechanac date, fechaactual date) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare 
g character varying(150);
begin
	g := replace(
			replace(
					replace(
						replace(
							replace(
								replace(
									upper((age($1,$2)) :: character varying)
									,'YEAR','año')
								,'YEARS','años')
						,'MONS','meses')
					,'MON','mes')
			,'DAY','día')
	,'DAYS','días');
	return g;
end;
$_$;


ALTER FUNCTION public.obteneredadestudiante(fechanac date, fechaactual date) OWNER TO postgres;

--
-- Name: obteneredadestudiante(integer, date, date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.obteneredadestudiante(idpersona integer, fechanac date, fechaactual date) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare 
g character varying(150);
begin
	g := replace(
			replace(
				replace(
					replace(
						upper((age($1,$2)) :: varchar)
					,'YEAR','año`(s)`')
				,'MONS','meses')
			,'MON','mes')
	,'DAY','días');
	return g;
end;
$_$;


ALTER FUNCTION public.obteneredadestudiante(idpersona integer, fechanac date, fechaactual date) OWNER TO postgres;

--
-- Name: registermovimiento(integer, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registermovimiento(idpersona integer, nivelpersona character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
 flagTrue integer :=1;
 fila detalle_cronograma%rowtype;
begin
	for fila in select * from detalle_cronograma where nivel = nivelPersona
		loop
			insert into movimiento(monto, id_persona, id_detalle_cronograma) values
			(fila.monto, idPersona, fila.id_detalle_cronograma);
		end loop;
	return flagTrue;
end;
$$;


ALTER FUNCTION public.registermovimiento(idpersona integer, nivelpersona character varying) OWNER TO postgres;

--
-- Name: registrarestudiante(character varying, character varying, character varying, date, text, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrarestudiante(nomperson character varying, apepateperson character varying, apemateperson character varying, fechanaci date, fotoruta text, idgrado integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
 idPerson integer;
begin
	insert into persona(nom_persona, ape_pate_pers, ape_mate_pers, fecha_naci, 
	foto_ruta, id_grado) values (nomPerson, apePatePerson, apeMatePerson, fechaNaci,
	fotoRuta, idGrado) returning id_persona into idPerson;
	return idPerson;
end;
$$;


ALTER FUNCTION public.registrarestudiante(nomperson character varying, apepateperson character varying, apemateperson character varying, fechanaci date, fotoruta text, idgrado integer) OWNER TO postgres;

--
-- Name: sp_get_listar_estudiantes(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sp_get_listar_estudiantes() RETURNS SETOF record
    LANGUAGE plpgsql
    AS $$
declare 
	r record;
begin
	for r in select nom_persona from persona
		loop
			return next r;
		end loop;
	return;
end;
$$;


ALTER FUNCTION public.sp_get_listar_estudiantes() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cronograma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cronograma (
    id_cronograma integer NOT NULL,
    year integer
);


ALTER TABLE public.cronograma OWNER TO postgres;

--
-- Name: cronograma_id_cronograma_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.cronograma ALTER COLUMN id_cronograma ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.cronograma_id_cronograma_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: detalle_cronograma; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detalle_cronograma (
    id_detalle_cronograma integer NOT NULL,
    id_cronograma integer,
    desc_pension character varying(50),
    monto numeric(11,2),
    fecha_venci date,
    nivel character varying(3)
);


ALTER TABLE public.detalle_cronograma OWNER TO postgres;

--
-- Name: detalle_cronograma_id_detalle_cronograma_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.detalle_cronograma ALTER COLUMN id_detalle_cronograma ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.detalle_cronograma_id_detalle_cronograma_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: grado; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.grado (
    id_grado integer NOT NULL,
    desc_grado character varying(50),
    nivel character varying(3)
);


ALTER TABLE public.grado OWNER TO postgres;

--
-- Name: grado_nid_grado_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.grado ALTER COLUMN id_grado ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.grado_nid_grado_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: movimiento; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movimiento (
    id_movimiento integer NOT NULL,
    tipo_movimiento character varying(20) DEFAULT 'INGRESO'::character varying,
    monto numeric(11,2),
    estado character varying(20) DEFAULT 'POR PAGAR'::character varying,
    fecha_pago date,
    id_persona integer,
    id_detalle_cronograma integer
);


ALTER TABLE public.movimiento OWNER TO postgres;

--
-- Name: movimiento_id_movimiento_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.movimiento ALTER COLUMN id_movimiento ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.movimiento_id_movimiento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: persona; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.persona (
    id_persona integer NOT NULL,
    nom_persona character varying(50),
    ape_pate_pers character varying(50),
    ape_mate_pers character varying(50),
    fecha_naci date,
    foto_ruta text,
    id_grado integer
);


ALTER TABLE public.persona OWNER TO postgres;

--
-- Name: persona_nid_persona_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.persona ALTER COLUMN id_persona ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.persona_nid_persona_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: cronograma; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cronograma (id_cronograma, year) FROM stdin;
1	2020
\.


--
-- Data for Name: detalle_cronograma; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detalle_cronograma (id_detalle_cronograma, id_cronograma, desc_pension, monto, fecha_venci, nivel) FROM stdin;
1	1	Matricula	300.00	2020-02-28	INI
2	1	Marzo	300.00	2020-03-30	INI
3	1	Abril	300.00	2020-04-30	INI
4	1	Mayo	300.00	2020-05-30	INI
5	1	Junio	300.00	2020-06-30	INI
6	1	Julio	300.00	2020-07-30	INI
7	1	Agosto	300.00	2020-08-30	INI
8	1	Septiembre	300.00	2020-09-30	INI
9	1	Octubre	300.00	2020-10-30	INI
10	1	Noviembre	300.00	2020-11-30	INI
11	1	Diciembre	300.00	2020-12-30	INI
12	1	Matricula	450.00	2020-02-28	PRI
13	1	Marzo	450.00	2020-03-30	PRI
14	1	Abril	450.00	2020-04-30	PRI
15	1	Mayo	450.00	2020-05-30	PRI
16	1	Junio	450.00	2020-06-30	PRI
17	1	Julio	450.00	2020-07-30	PRI
18	1	Agosto	450.00	2020-08-30	PRI
19	1	Septiembre	450.00	2020-09-30	PRI
20	1	Octubre	450.00	2020-10-30	PRI
21	1	Noviembre	450.00	2020-11-30	PRI
22	1	Diciembre	450.00	2020-12-30	PRI
23	1	Matricula	540.00	2020-02-28	SEC
24	1	Marzo	540.00	2020-03-30	SEC
25	1	Abril	540.00	2020-04-30	SEC
26	1	Mayo	540.00	2020-05-30	SEC
27	1	Junio	540.00	2020-06-30	SEC
28	1	Julio	540.00	2020-07-30	SEC
29	1	Agosto	540.00	2020-08-30	SEC
30	1	Septiembre	540.00	2020-09-30	SEC
31	1	Octubre	540.00	2020-10-30	SEC
32	1	Noviembre	540.00	2020-11-30	SEC
33	1	Diciembre	540.00	2020-12-30	SEC
\.


--
-- Data for Name: grado; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.grado (id_grado, desc_grado, nivel) FROM stdin;
1	1 año	INI
2	2 año	INI
3	3 año	INI
4	4 año	INI
5	5 año	INI
6	Primero	PRI
7	Segundo	PRI
8	Tercero	PRI
9	Cuarto	PRI
10	Quinto	PRI
11	Sexto	PRI
12	Primero	SEC
13	Segundo	SEC
14	Tercero	SEC
15	Cuarto	SEC
16	Quinto	SEC
17	Sexto	SEC
18	Nido	INI
\.


--
-- Data for Name: movimiento; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movimiento (id_movimiento, tipo_movimiento, monto, estado, fecha_pago, id_persona, id_detalle_cronograma) FROM stdin;
1	INGRESO	300.00	POR PAGAR	2020-02-28	1	1
6	INGRESO	300.00	POR PAGAR	\N	2	5
7	INGRESO	300.00	POR PAGAR	\N	2	6
8	INGRESO	300.00	POR PAGAR	\N	2	7
9	INGRESO	300.00	POR PAGAR	\N	2	8
10	INGRESO	300.00	POR PAGAR	\N	2	9
11	INGRESO	300.00	POR PAGAR	\N	2	10
12	INGRESO	300.00	POR PAGAR	\N	2	11
14	INGRESO	450.00	POR PAGAR	\N	6	12
15	INGRESO	450.00	POR PAGAR	\N	6	13
16	INGRESO	450.00	POR PAGAR	\N	6	14
17	INGRESO	450.00	POR PAGAR	\N	6	15
18	INGRESO	450.00	POR PAGAR	\N	6	16
19	INGRESO	450.00	POR PAGAR	\N	6	17
20	INGRESO	450.00	POR PAGAR	\N	6	18
21	INGRESO	450.00	POR PAGAR	\N	6	19
22	INGRESO	450.00	POR PAGAR	\N	6	20
23	INGRESO	450.00	POR PAGAR	\N	6	21
24	INGRESO	450.00	POR PAGAR	\N	6	22
2	INGRESO	300.00	PAGADO	2020-11-29	2	1
3	INGRESO	300.00	PAGADO	2020-11-29	2	2
4	INGRESO	300.00	PAGADO	2020-11-29	2	3
5	INGRESO	300.00	PAGADO	2020-11-29	2	4
25	INGRESO	300.00	POR PAGAR	\N	15	1
26	INGRESO	300.00	POR PAGAR	\N	15	2
27	INGRESO	300.00	POR PAGAR	\N	15	3
28	INGRESO	300.00	POR PAGAR	\N	15	4
29	INGRESO	300.00	POR PAGAR	\N	15	5
30	INGRESO	300.00	POR PAGAR	\N	15	6
31	INGRESO	300.00	POR PAGAR	\N	15	7
32	INGRESO	300.00	POR PAGAR	\N	15	8
33	INGRESO	300.00	POR PAGAR	\N	15	9
34	INGRESO	300.00	POR PAGAR	\N	15	10
35	INGRESO	300.00	POR PAGAR	\N	15	11
\.


--
-- Data for Name: persona; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.persona (id_persona, nom_persona, ape_pate_pers, ape_mate_pers, fecha_naci, foto_ruta, id_grado) FROM stdin;
1	Clifford	Garate	Pardo	1999-07-13	foto.png	15
2	Juan	Lopez	Perez	1998-05-23	image.png	5
6	Juan	Lopez	Perez	1998-05-23	image.png	5
7	Marcos	Lopez	Perez	1998-05-23	imageasdsdsadasdasdasdadsdsad.png	5
8	Rodrigo	Sanchez	Ramal	2000-05-23	-mWp3KJDhOBycu54JprrTBmy.png	8
9	Joel	Cruz	Ramal	1999-07-23	rO2_kr9HcwwD4lLstNrr8i2A.png	10
10	Diego	Belaunde	Ramal	1999-07-23	gABti1ikYXYb3YJgTdOZkbo3.png	10
11	Valeria	Belaunde	Rodriguez	1999-07-23	7njWY4Uaqe_th72E_mrA7YdB.png	14
12	Chris	Garner	Reyes	2010-05-23	PBu_xf-TLf9f3XmNk66GjXtB.png	5
13	Miguel	Ramirez	Palomino	2018-05-10	G6yypTuXQp2eE87AE4_xAI5V.png	2
14	Miguel	Ramirez	Palomino	2018-05-10	s76cjBzCpEciB5SFEax5POCZ.png	2
15	Miguel	Ramirez	Palomino	2018-05-10	Qm-h4Ml3Z751HwpTfSTg_alg.png	2
\.


--
-- Name: cronograma_id_cronograma_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cronograma_id_cronograma_seq', 1, true);


--
-- Name: detalle_cronograma_id_detalle_cronograma_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.detalle_cronograma_id_detalle_cronograma_seq', 33, true);


--
-- Name: grado_nid_grado_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.grado_nid_grado_seq', 18, true);


--
-- Name: movimiento_id_movimiento_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movimiento_id_movimiento_seq', 35, true);


--
-- Name: persona_nid_persona_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.persona_nid_persona_seq', 15, true);


--
-- Name: cronograma cronograma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cronograma
    ADD CONSTRAINT cronograma_pkey PRIMARY KEY (id_cronograma);


--
-- Name: detalle_cronograma detalle_cronograma_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_cronograma
    ADD CONSTRAINT detalle_cronograma_pkey PRIMARY KEY (id_detalle_cronograma);


--
-- Name: grado grado_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.grado
    ADD CONSTRAINT grado_pkey PRIMARY KEY (id_grado);


--
-- Name: movimiento movimiento_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento
    ADD CONSTRAINT movimiento_pkey PRIMARY KEY (id_movimiento);


--
-- Name: persona persona_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT persona_pkey PRIMARY KEY (id_persona);


--
-- Name: detalle_cronograma id_cronograma; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detalle_cronograma
    ADD CONSTRAINT id_cronograma FOREIGN KEY (id_cronograma) REFERENCES public.cronograma(id_cronograma) NOT VALID;


--
-- Name: movimiento id_detalle_cronograma; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento
    ADD CONSTRAINT id_detalle_cronograma FOREIGN KEY (id_detalle_cronograma) REFERENCES public.detalle_cronograma(id_detalle_cronograma) NOT VALID;


--
-- Name: persona id_grado; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.persona
    ADD CONSTRAINT id_grado FOREIGN KEY (id_grado) REFERENCES public.grado(id_grado);


--
-- Name: movimiento id_persona; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movimiento
    ADD CONSTRAINT id_persona FOREIGN KEY (id_persona) REFERENCES public.persona(id_persona);


--
-- PostgreSQL database dump complete
--

