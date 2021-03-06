classdef PTSD_EventType
    %PTSD_EVENTTYPE Defines the set of events that can happen in a PTSD
    %M-Maze behavior session.
    
    methods (Static)
        
        function is_sound = IsSoundEvent ( event_type )
            
            is_sound = (event_type == PTSD_EventType.FEAR | ...
                event_type == PTSD_EventType.NAIVE | ...
                event_type == PTSD_EventType.TRAUMA | ...
                event_type == PTSD_EventType.MACHINE_GUN | ...
                event_type == PTSD_EventType.TWITTER | ...
                event_type == PTSD_EventType.NINE_KHZ | ...
                event_type == PTSD_EventType.NINE_KHZ_30SECONDS | ...
                event_type == PTSD_EventType.GUNFIRE_30SECONDS);
            
        end
        
        function is_silent_sound = IsSilentEvent ( event_type )
            
            is_silent_sound = (event_type == PTSD_EventType.UNKNOWN_EVENT);
            
        end
        
        function is_feeder = IsFeederEvent ( event_type )
            is_feeder = (event_type == PTSD_EventType.LEFT_FEEDER_TRIGGERED | ...
                event_type == PTSD_EventType.RIGHT_FEEDER_TRIGGERED );
        end
        
        function is_nosepoke_in = IsNosepokeEnterEvent ( event_type )
            is_nosepoke_in = (event_type == PTSD_EventType.LEFT_NOSEPOKE_ENTER | ...
                event_type == PTSD_EventType.RIGHT_NOSEPOKE_ENTER );
        end
        
        function is_nosepoke_out = IsNosepokeExitEvent ( event_type )
            is_nosepoke_out = (event_type == PTSD_EventType.LEFT_NOSEPOKE_LEAVE | ...
                event_type == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE );
        end
        
        function is_nosepoke_event = IsNosepokeEvent ( event_type )
            is_nosepoke_event = (event_type == PTSD_EventType.LEFT_NOSEPOKE_LEAVE | ...
                event_type == PTSD_EventType.RIGHT_NOSEPOKE_LEAVE | ...
                event_type == PTSD_EventType.LEFT_NOSEPOKE_ENTER | ...
                event_type == PTSD_EventType.RIGHT_NOSEPOKE_ENTER );
        end
        
    end
    
    properties (Constant)
        LEFT_NOSEPOKE_ENTER = 1;
        LEFT_NOSEPOKE_LEAVE = 2;
        LEFT_PROX_ENTER = 3;
        LEFT_PROX_LEAVE = 4;
        RIGHT_PROX_ENTER = 5;
        RIGHT_PROX_LEAVE = 6;
        RIGHT_NOSEPOKE_ENTER = 7;
        RIGHT_NOSEPOKE_LEAVE = 8;
        RIGHT_FEEDER_TRIGGERED = 9;
        LEFT_FEEDER_TRIGGERED = 10;
        
        FEAR = 11;
        TRAUMA = 12;
        NAIVE = 13;
        
        MACHINE_GUN = 14;
        TWITTER = 15;
        NINE_KHZ = 16;
        NINE_KHZ_30SECONDS = 17;
        GUNFIRE_30SECONDS = 18;
        
        TOTAL_FEEDS = 30;
        TOTAL_NOSEPOKES = 31;
        LEFT_NOSEPOKES = 32;
        RIGHT_NOSEPOKES = 33;
        LEFT_FEEDS = 34;
        RIGHT_FEEDS = 35;
        
        UNKNOWN_EVENT = -1;
        SILENT_SESSION = -2;
        ANY_SOUND = -3;
        PRE_POST = -4;
        
        
        event_colors = [ ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            0 0 0; ...
            1 0 0; ...
            0 0.7 0; ...
            0 0 1; ...
            1 0 0; ...
            0 0.7 0; ...
            0 0 1; ...
            0 0 1; ...
            1 0 0];
        
        event_input_strings = { ...
            'LEFT_NOSEPOKE_ENTER', ...
            'LEFT_NOSEPOKE_LEAVE', ...
            'LEFT_PROX_ENTER', ...
            'LEFT_PROX_LEAVE', ...
            'RIGHT_PROX_ENTER', ...
            'RIGHT_PROX_LEAVE', ...
            'RIGHT_NOSEPOKE_ENTER', ...
            'RIGHT_NOSEPOKE_LEAVE', ...
            'RIGHT_FEEDER_TRIGGERED', ...
            'LEFT_FEEDER_TRIGGERED', ...
            'fear', ...
            'trauma', ...
            'naive', ...
            'sounds/track001.wav', ...
            'sounds/twitter_7.wav', ...
            'sounds/9khz_32bit.wav', ...
            'sounds/9khz.mp3', ...
            'sounds/track001.mp3' ...
        };
        
        event_display_strings = { ...
            'LEFT_NOSEPOKE_ENTER', ...
            'LEFT_NOSEPOKE_LEAVE', ...
            'LEFT_PROX_ENTER', ...
            'LEFT_PROX_LEAVE', ...
            'RIGHT_PROX_ENTER', ...
            'RIGHT_PROX_LEAVE', ...
            'RIGHT_NOSEPOKE_ENTER', ...
            'RIGHT_NOSEPOKE_LEAVE', ...
            'RIGHT_FEEDER_TRIGGERED', ...
            'LEFT_FEEDER_TRIGGERED', ...
            'fear', ...
            'trauma', ...
            'naive', ...
            'machine gun', ...
            'twitter', ...
            'tone', ...
            '30-second tone', ...
            '30-second gunfire' ...
        };
    end
    
end

