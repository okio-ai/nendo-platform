DO $$ 
DECLARE
    desired_count INTEGER := 100; -- Change this to the number you want
    generated_code VARCHAR(8);
    iter INTEGER := 0;
BEGIN

    -- Loop until we've inserted the desired number of unique codes
    WHILE iter < desired_count LOOP
        -- Generate a random 8-character alphanumeric string (upper-case)
        generated_code := (SELECT LEFT(UPPER(MD5(RANDOM()::text)), 8));
        
        -- If the code doesn't already exist, insert it
        IF NOT EXISTS (SELECT 1 FROM user_invite_code WHERE invite_code = generated_code) THEN
            INSERT INTO user_invite_code(invite_code) VALUES (generated_code);
            iter := iter + 1;
        END IF;
        
    END LOOP;

END $$;