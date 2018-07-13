classdef MobileUser
    %MOBILEUSER Summary of this class goes here
    
    properties
        xPos
        yPos
        move
    end
    
    methods
        function obj = MobileUser(xPos, yPos, move)
            %ACCESSPOINT Construct an instance of this class
            
            if nargin > 0
                if isnumeric(xPos)
                    obj.xPos = xPos;
                else
                    error('xPos value must be a numeric')
                end
                
                if isnumeric(yPos)
                    obj.yPos = yPos;
                else
                    error('yPos value must be a numberic')
                end
                
                if (move==1)||(move==0)
                    obj.move=move;
                else
                    error('move value must be a binary')
                end
            end
        end
    end
end

