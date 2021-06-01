-Criação das funções

CREATE OR REPLACE FUNCTION abrirConta(cliente_ varchar, agencia_ int, numero_ int, valor_ numeric)
RETURNS void as $$
BEGIN
	INSERT INTO conta VALUES (agencia_,numero_,cliente_,valor_,'true');
END;
$$ LANGUAGE PLPGSQL;

SELECT abrirConta('Alysson',332,12345,300.50);
SELECT abrirConta('Camilly',342,54321,400.00);
SELECT abrirConta('José',332,98102,350.00);


CREATE OR REPLACE FUNCTION exibirSaldo(agencia_ int, numero_ int)
RETURNS numeric(12,2) AS $$
DECLARE
	saldoConta numeric(12,2);
BEGIN
	 SELECT saldo into saldoConta FROM conta 
	 WHERE agencia = agencia_ and numero = numero_;
	 RETURN saldoConta;
END;
$$ LANGUAGE PLPGSQL;

SELECT exibirSaldo(332,12345);


CREATE OR REPLACE FUNCTION depositar(agencia_ int, numero_ int, valor_ numeric(12,2))
RETURNS void AS $$
BEGIN
	UPDATE conta SET saldo = saldo + valor_ WHERE agencia = agencia_ and numero = numero_;
END;
$$ LANGUAGE PLPGSQL;

SELECT depositar(332,12345,10);


CREATE OR REPLACE FUNCTION sacar(agencia_ int, numero_ int, valor_ numeric(12,2))
RETURNS void AS $$
BEGIN
	UPDATE conta SET saldo = saldo - valor_ WHERE agencia = agencia_ and numero = numero_;
END;
$$ LANGUAGE PLPGSQL;

SELECT sacar(332,12345,0.50);


CREATE OR REPLACE FUNCTION 
transferir(agenciaOrigem int, numeroOrigem int, agenciaDestino int, numeroDestino int,  valor numeric(12,2))
RETURNS void AS $$
BEGIN
	UPDATE conta SET saldo = saldo - valor WHERE agencia = agenciaOrigem and numero = numeroOrigem;
	UPDATE conta SET saldo = saldo + valor WHERE agencia = agenciaDestino and numero = numeroDestino;
END;
$$ LANGUAGE PLPGSQL;


Criação da auditoria(TRIGGER)

CREATE OR REPLACE FUNCTION conta_audit()
RETURNS TRIGGER AS $$
BEGIN
	IF (TG_OP = 'DELETE') THEN
		INSERT INTO contaAuditoria SELECT 'D', user,  now(), OLD.agencia, OLD.numero, OLD.cliente, OLD.saldo, OLD.ativa;
	ELSIF (TG_OP = 'UPDATE') THEN
		INSERT INTO contaAuditoria SELECT 'U', user,  now(), NEW.agencia, NEW.numero, NEW.cliente, NEW.saldo, NEW.ativa;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO contaAuditoria SELECT 'I', user,  now(), NEW.agencia, NEW.numero, NEW.cliente, NEW.saldo, NEW.ativa;
	END IF;
	RETURN null;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER contaAuditoria
AFTER INSERT OR UPDATE OR DELETE
ON conta FOR EACH ROW EXECUTE PROCEDURE conta_audit();

SELECT * FROM contaAuditoria;

SELECT transferir(342,54321,332,12345,15);


CREATE OR REPLACE FUNCTION bloquearConta(agencia_ int, numero_ int)
RETURNS void AS $$
BEGIN
	UPDATE conta SET ativa = false WHERE agencia = agencia_ AND numero = numero_; 
END;
$$ LANGUAGE PLPGSQL; 

SELECT bloquearConta(332,12345);


CREATE OR REPLACE FUNCTION desbloquearConta(agencia_ int, numero_ int)
RETURNS void AS $$
BEGIN
	UPDATE conta SET ativa = true WHERE agencia = agencia_ AND numero = numero_; 
END;
$$ LANGUAGE PLPGSQL; 

SELECT desbloquearConta(332,12345);
