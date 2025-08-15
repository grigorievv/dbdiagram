
workspace "Payment Domain" "C4 model for payment processing with check and pay services" {

    !identifiers hierarchical

    model {
        // Акторы
        u = person "Customer" "Initiates payment via mobile app or web portal"
        ba = person "Bank Admin" "Monitors and manages payment operations"

        // Основная система
        ps = softwareSystem "Payment Platform" "Handles payment validation and execution" {
            
            // Контейнеры
            api = container "API Gateway" "Routes requests to payment services" "Java + Spring Boot"
            check = container "Check Service" "Validates payment requests (balance, limits, fraud)" "Java + Spring Boot" {
                // Компоненты Check Service
                cc = component "Validation Controller" "REST endpoint for payment validation"
                cl = component "Limit Checker" "Validates daily and transaction limits"
                cf = component "Fraud Detector" "Performs fraud checks"
                cb = component "Balance Verifier" "Checks if customer has enough balance"
            }
            pay = container "Pay Service" "Executes payments and updates transaction status" "Java + Spring Boot" {
                // Компоненты Pay Service
                pc = component "Payment Controller" "REST endpoint for payment execution"
                pp = component "Payment Processor" "Handles core payment execution logic"
                psb = component "Settlement Bridge" "Integrates with external clearing/settlement systems"
            }
            db = container "Payment DB" "Stores payment transactions and logs" "PostgreSQL"
            mq = container "Message Broker" "Asynchronous events between services" "Kafka"
        }

        // Связи на уровне System Context
        u -> ps.api "Initiates payment via mobile/web"
        ba -> ps.api "Monitors payments via admin console"

        // Связи на уровне Container
        ps.api -> ps.check "Validates payment requests"
        ps.api -> ps.pay "Executes payments after validation"
        ps.check -> ps.db "Reads customer/account data"
        ps.check -> ps.mq "Publishes validation events"
        ps.pay -> ps.db "Writes payment transactions"
        ps.pay -> ps.mq "Publishes payment events"

        // Связи внутри Check Service
        ps.api -> ps.check.cc "Calls validation endpoint"
        ps.check.cc -> ps.check.cl "Checks limits"
        ps.check.cc -> ps.check.cf "Performs fraud detection"
        ps.check.cc -> ps.check.cb "Checks balance"
        ps.check.cb -> ps.db "Reads account balance"

        // Связи внутри Pay Service
        ps.api -> ps.pay.pc "Calls payment execution endpoint"
        ps.pay.pc -> ps.pay.pp "Processes payment request"
        ps.pay.pp -> ps.pay.psb "Sends payment to settlement"
        ps.pay.pp -> ps.db "Stores transaction result"
    }

    views {
        // System Context
        systemContext ps "SystemContext" {
            include *
            autolayout lr
        }

        // Container
        container ps "ContainerDiagram" {
            include *
            autolayout lr
        }

        // Component для Check Service
        component ps.check "CheckServiceComponents" {
            include *
            autolayout lr
        }

        // Component для Pay Service
        component ps.pay "PayServiceComponents" {
            include *
            autolayout lr
        }
    }
}

