-- Public Tool Useful APIs



-- Method:          GRM.ClearFriendsList()
-- What it Does:    Clears the entire server side, non-battletag friends list completely to zero
-- Purpose:         For debugging cleanup
GRM.ClearFriendsList = function()
    for i = C_FriendList.GetNumFriends() , 1 , -1 do
        local name = C_FriendList.GetFriendInfoByIndex ( i ).name;
        C_FriendList.RemoveFriend ( name );
    end
end
