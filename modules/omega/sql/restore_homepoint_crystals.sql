UPDATE npc_list
SET content_tag = NULL
WHERE (name LIKE 'HomePoint%' OR name LIKE 'Home_Point%')
  AND content_tag = 'SOA';