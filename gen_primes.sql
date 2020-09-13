create or replace procedure gen_primes(aCnt in int)
is
  cnt int := 0;
  numb int := 1;
begin
  execute immediate 'truncate table prime';
  while cnt < aCnt loop
    numb := numb + 1;
    if is_prime(numb)
    then insert into prime values (numb);
    cnt:= cnt +1;
    end if;
  end loop;
  execute immediate 'select * from prime';
end gen_primes;
/