# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

Kind           = "service-resolver"
Name           = "payments"
ConnectTimeout = "0s"
Failover = {
  "*" = {
    Datacenters = ["dc2", "dc1"]
  }
}