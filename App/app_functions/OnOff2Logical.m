function tf =  OnOff2Logical( OnOffString )

if string(OnOffString) == "on"  || string(OnOffString) == "On"
    tf = true;
elseif  string(OnOffString) == "off"  || string(OnOffString) == "Off"
    tf = false;
else
    error("Wrong string");
end


end