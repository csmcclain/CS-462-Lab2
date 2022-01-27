ruleset wovyn_base {

    // meta {
    //     use module twilio.api alias twilio
    //         with
    //             accountSid = meta:rulesetConfig{"accountSid"}
    //             authToken = meta:rulesetConfig{"authToken"}
    // }

    // Define global variables.
    global {
        temperature_threshold = 72
        sender_of_sms = "" //TODO: SET ME BEFORE APPLYING
        receiver_of_sms = "" //TODO: SET ME BEFORE APPLYING
    }


    rule process_heartbeet {
        // Define when rule is selected
        select when wovyn heartbeat

        // Set variables that are be needed (prelude)
        pre {
            genericThing = event:attrs{"genericThing"}.klog("Received genericThing: ")
            time = time:now().klog("Read time at: ")
        }        

        // Define the action to be taken (action)
        // Action will not be taken when when genericThing is null
        if (genericThing) then noop()

        // Clean up based on what happened (postlude)
        // Postlude will be evaluated if the action above (noop) is fired
        fired {
            raise wovyn event "new_temperature_reading" attributes {
                "temperature": genericThing{"data"}{"temperature"}[0]{"temperatureF"},
                "timestamp": time
            }
        }
    }

    rule find_high_temps {
        // Define when the rule is selected
        select when wovyn new_temperature_reading

        // Set variables that are needed (prelude)
        pre {
            temperature = event:attrs{"temperature"}.klog("Received the following temperature in find_high_temps: ")
            timestamp = event:attrs{"timestamp"}
        }

        // Action will be taken depending if the temperature exceeds the threshold
        if (temperature > temperature_threshold) then noop()

        //Postlude will be evaulated if the action is fired
        fired {
            raise wovyn event "threshold_violation" attributes {
                "temperature": temperature,
                "timestamp": timestamp
            }
        }
    }

    // rule threshold_notification {
    //     // Define when the rule is selected
    //     select when wovyn threshold_violation

    //     // Set variables that are needed (prelude)
    //     pre {
    //         message = "A reading of " + event:attrs{"temperature"} + " was read at " + event:attrs{"timestamp"}
    //     }

    //     // No action is needed we will always evaluate the postlude
    //     twilio:sendSMS(receiver_of_sms, sender_of_sms, message)
    // }

}