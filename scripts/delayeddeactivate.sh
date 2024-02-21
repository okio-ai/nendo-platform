#!/bin/bash

USER_ID=$1
at now + 3 days <<EOF
docker exec nendo-postgres psql -U nendo -d auth -c "UPDATE users set is_active=false where id='$1'"
EOF
