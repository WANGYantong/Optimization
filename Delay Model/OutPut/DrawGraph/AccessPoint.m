classdef AccessPoint
    
    properties
        xPos    % x axis position
        yPos    % y axis position
    end
    
    methods
        function obj = AccessPoint(xPos, yPos)
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
            end
        end
    end
    
end

