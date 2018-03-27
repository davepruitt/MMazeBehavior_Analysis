classdef PTSD_Session_Segment
    % This class is meant to describe segments of a session during which a
    % 30-second sound plays.  It retains information about the 30 seconds
    % before the sound as well as the 30 seconds after the sound.
    
    properties
        
        EventType
        EventTime
        
        TotalLeftNosepokeEvents
        TotalRightNosepokeEvents
        TotalLeftProxEvents
        TotalRightProxEvents
        TotalLeftFeederEvents
        TotalRightFeederEvents
        
        TotalNosepokeEvents
        TotalProxEvents
        TotalFeederEvents
        
        TotalEvents
        
    end
    
    methods
        
        function obj = PTSD_Session_Segment ( event_types, event_times )
            
            obj.EventType = event_types;
            obj.EventTime = event_times;
            
            obj.TotalLeftNosepokeEvents = length(find(obj.EventType == PTSD_EventType.LEFT_NOSEPOKE_ENTER | ...
                obj.EventType == PTSD_EventType.LEFT_NOSEPOKE_LEAVE));
            obj.TotalRightNosepokeEvents = length(find(obj.EventType == PTSD_EventType.RIGHT_NOSEPOKE_ENTER | ...
                obj.EventType == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE));
            obj.TotalLeftProxEvents = length(find(obj.EventType == PTSD_EventType.LEFT_PROX_ENTER | ...
                obj.EventType == PTSD_EventType.LEFT_PROX_LEAVE));
            obj.TotalRightProxEvents = length(find(obj.EventType == PTSD_EventType.RIGHT_PROX_ENTER | ...
                obj.EventType == PTSD_EventType.RIGHT_PROX_LEAVE));
            obj.TotalLeftFeederEvents = length(find(obj.EventType == PTSD_EventType.LEFT_FEEDER_TRIGGERED));
            obj.TotalRightFeederEvents = length(find(obj.EventType == PTSD_EventType.RIGHT_FEEDER_TRIGGERED));
            
            obj.TotalNosepokeEvents = obj.TotalLeftNosepokeEvents + obj.TotalRightNosepokeEvents;
            obj.TotalProxEvents = obj.TotalLeftProxEvents + obj.TotalRightProxEvents;
            obj.TotalFeederEvents = obj.TotalLeftFeederEvents + obj.TotalRightFeederEvents;
            
            obj.TotalEvents = obj.TotalNosepokeEvents + obj.TotalProxEvents + obj.TotalFeederEvents;
            
        end
        
    end
    
    methods (Static)
       
        function obj = SubtractSegments ( seg1, seg2 )
            
            %Create an empty PTSD_Session_Segment object
            obj = PTSD_Session_Segment( [], [] );
            
            %Set the properties of the difference segment
            obj.TotalLeftNosepokeEvents = seg1.TotalLeftNosepokeEvents - seg2.TotalLeftNosepokeEvents;
            obj.TotalRightNosepokeEvents = seg1.TotalRightNosepokeEvents - seg2.TotalRightNosepokeEvents;
            obj.TotalLeftProxEvents = seg1.TotalLeftProxEvents - seg2.TotalLeftProxEvents;
            obj.TotalRightProxEvents = seg1.TotalRightProxEvents - seg2.TotalRightProxEvents;
            obj.TotalLeftFeederEvents = seg1.TotalLeftFeederEvents - seg2.TotalLeftFeederEvents;
            obj.TotalRightFeederEvents = seg1.TotalRightFeederEvents - seg2.TotalRightFeederEvents;

            obj.TotalNosepokeEvents = seg1.TotalNosepokeEvents - seg2.TotalNosepokeEvents;
            obj.TotalProxEvents = seg1.TotalProxEvents - seg2.TotalProxEvents;
            obj.TotalFeederEvents = seg1.TotalFeederEvents - seg2.TotalFeederEvents;

            obj.TotalEvents = seg1.TotalEvents - seg2.TotalEvents;
            
        end
        
        function obj = AddSegments ( seg1, seg2 )
            
            %Create an empty PTSD_Session_Segment object
            obj = PTSD_Session_Segment( [], [] );
            
            %Set the properties of the difference segment
            obj.TotalLeftNosepokeEvents = seg1.TotalLeftNosepokeEvents + seg2.TotalLeftNosepokeEvents;
            obj.TotalRightNosepokeEvents = seg1.TotalRightNosepokeEvents + seg2.TotalRightNosepokeEvents;
            obj.TotalLeftProxEvents = seg1.TotalLeftProxEvents + seg2.TotalLeftProxEvents;
            obj.TotalRightProxEvents = seg1.TotalRightProxEvents + seg2.TotalRightProxEvents;
            obj.TotalLeftFeederEvents = seg1.TotalLeftFeederEvents + seg2.TotalLeftFeederEvents;
            obj.TotalRightFeederEvents = seg1.TotalRightFeederEvents + seg2.TotalRightFeederEvents;

            obj.TotalNosepokeEvents = seg1.TotalNosepokeEvents + seg2.TotalNosepokeEvents;
            obj.TotalProxEvents = seg1.TotalProxEvents + seg2.TotalProxEvents;
            obj.TotalFeederEvents = seg1.TotalFeederEvents + seg2.TotalFeederEvents;

            obj.TotalEvents = seg1.TotalEvents + seg2.TotalEvents;
            
        end
        
        function obj = DivideSegments ( seg1, seg2 )
            
            % seg1 = numerator
            % seg2 = denominator
            
            %Create an empty PTSD_Session_Segment object
            obj = PTSD_Session_Segment( [], [] );
            
            %Set the properties of the difference segment
            obj.TotalLeftNosepokeEvents = seg1.TotalLeftNosepokeEvents / seg2.TotalLeftNosepokeEvents;
            obj.TotalRightNosepokeEvents = seg1.TotalRightNosepokeEvents / seg2.TotalRightNosepokeEvents;
            obj.TotalLeftProxEvents = seg1.TotalLeftProxEvents / seg2.TotalLeftProxEvents;
            obj.TotalRightProxEvents = seg1.TotalRightProxEvents / seg2.TotalRightProxEvents;
            obj.TotalLeftFeederEvents = seg1.TotalLeftFeederEvents / seg2.TotalLeftFeederEvents;
            obj.TotalRightFeederEvents = seg1.TotalRightFeederEvents / seg2.TotalRightFeederEvents;

            obj.TotalNosepokeEvents = seg1.TotalNosepokeEvents / seg2.TotalNosepokeEvents;
            obj.TotalProxEvents = seg1.TotalProxEvents / seg2.TotalProxEvents;
            obj.TotalFeederEvents = seg1.TotalFeederEvents / seg2.TotalFeederEvents;

            obj.TotalEvents = seg1.TotalEvents / seg2.TotalEvents;
            
        end
        
        function obj = DivideSegmentByScalar ( seg1, scalar_value )
            
            % seg1 = numerator
            
            %Create an empty PTSD_Session_Segment object
            obj = PTSD_Session_Segment( [], [] );
            
            %Set the properties of the difference segment
            obj.TotalLeftNosepokeEvents = seg1.TotalLeftNosepokeEvents / scalar_value;
            obj.TotalRightNosepokeEvents = seg1.TotalRightNosepokeEvents / scalar_value;
            obj.TotalLeftProxEvents = seg1.TotalLeftProxEvents / scalar_value;
            obj.TotalRightProxEvents = seg1.TotalRightProxEvents / scalar_value;
            obj.TotalLeftFeederEvents = seg1.TotalLeftFeederEvents / scalar_value;
            obj.TotalRightFeederEvents = seg1.TotalRightFeederEvents / scalar_value;

            obj.TotalNosepokeEvents = seg1.TotalNosepokeEvents / scalar_value;
            obj.TotalProxEvents = seg1.TotalProxEvents / scalar_value;
            obj.TotalFeederEvents = seg1.TotalFeederEvents / scalar_value;

            obj.TotalEvents = seg1.TotalEvents / scalar_value;
            
        end
        
    end
    
end

















