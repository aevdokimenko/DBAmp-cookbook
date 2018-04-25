select name, membercount, id, LastFeedModifiedDate
from CollaborationGroup
where isarchived = 'false'
and MemberCount > 100
order by membercount desc