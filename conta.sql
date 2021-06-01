CREATE TABLE conta(
agencia int,
numero int,
cli varchar(100),
saldo numeric(12, 2),
ativa boolean
);

create table contaAuditoria(
    opera varchar(100),
    usuario varchar(100),
 	tempo timestamp,
	agencia int,
  numero int,
  cli varchar(100),
  saldo numeric(12, 2),
  ativa boolean
);




CREATE OR REPLACE FUNCTION abrirConta(cli_ varchar, agen int, numer int, valor numeric)
RETURNS void as $$
BEGIN
	INSERT INTO conta VALUES (agen,numer,cli_,valor,'true');
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION exibirSaldo(agen int, numer int)
RETURNS numeric(12,2) AS $$
DECLARE
	saldoConta numeric(12,2);
BEGIN
	 SELECT saldo into saldoConta FROM conta 
	 WHERE agencia = agen and numero = numer;
	 RETURN saldoConta;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION depositar(agen int, numer int, val numeric(12,2))
RETURNS void AS $$
BEGIN
	UPDATE conta SET saldo = saldo + val WHERE agencia = agen and numero = numer;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION sacar(agen int, numer int, val numeric(12,2))
RETURNS void AS $$
BEGIN
	UPDATE conta SET saldo = saldo - val WHERE agencia = agen and numero = numer;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION 
transferir(agenciaTransferir int, numeroTransferir int, agenciaReceber int, numeroReceber int,  val numeric(12,2))
RETURNS void AS $$
BEGIN
	UPDATE conta SET saldo = saldo - val WHERE agencia = agenciaTransferir and numero = numeroTransferir;
	UPDATE conta SET saldo = saldo + val WHERE agencia = agenciaReceber and numero = numeroReceber;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION bloquearConta(agen int, numer int)
RETURNS void AS $$
BEGIN
	UPDATE conta SET ativa = false WHERE agencia = agen AND numero = numer; 
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION desbloquearConta(agen int, numer int)
RETURNS void AS $$
BEGIN
	UPDATE conta SET ativa = true WHERE agencia = agen AND numero = numer; 
END;
$$ LANGUAGE PLPGSQL;





CREATE OR REPLACE FUNCTION conta_audit()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO contaAuditoria SELECT 'D', user,  now(), OLD.agencia, OLD.numero, OLD.cli, OLD.saldo, OLD.ativa;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO contaAuditoria SELECT 'U', user,  now(), NEW.agencia, NEW.numero, NEW.cli, NEW.saldo, NEW.ativa;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO contaAuditoria SELECT 'I', user,  now(), NEW.agencia, NEW.numero, NEW.cli, NEW.saldo, NEW.ativa;
	END IF;
	RETURN null;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER contaAuditoria
AFTER INSERT OR UPDATE OR DELETE
ON conta FOR EACH ROW EXECUTE PROCEDURE conta_audit();

