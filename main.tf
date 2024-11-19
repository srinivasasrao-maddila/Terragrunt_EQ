resource "newrelic_one_dashboard" "application" {
  name = "${var.eq_application} Monitoring Dashboard"
  
  page {
    name = "${var.eq_application} Status"
	
    widget_billboard {
      title = "Current Alerts Open"
      row = 1
      column = 1
	  width = 1
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentId) AS incidents FROM NrAiIncident WHERE policyName IN ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' WHERE event = 'open' since 1 day ago"
      }
	  critical = 5
    }
	
    widget_billboard {
      title = "Currrent APM Anomalies"
      row = 1
      column = 2
	  width = 1
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentID) AS anomalies FROM NrAiIncident WHERE evaluationType = 'anomaly' AND entity.name LIKE '%${var.apm_name}%' WHERE Event = 'open'"
      }
	  warning = 0
	  critical = 1
    }		

    widget_table {
      title = "Synthetics Success Rate"
      row = 1
      column = 3
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT percentage(count(*), where result = 'SUCCESS') as 'Availability%' FROM SyntheticCheck WHERE monitorName LIKE '%${var.synthetic_name}%' SINCE 15 minutes ago FACET monitorName "
      }
    }

	dynamic "widget_line" {

 for_each = var.sql_cluster == "true" ? [1] : []
 
	content {
      title = "Lock Waits Per Second"
      row = 4
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(`mssql.instance.stats.lockWaitsPerSecond`) FROM Metric timeseries since 1 hour ago FACET entity.name WHERE entity.name LIKE '%${var.sql_cluster1}%' OR entity.name LIKE '%${var.sql_cluster2}%'"
      }
    }
}
	dynamic "widget_line" {

 for_each = var.sql_cluster == "true" ? [1] : []
 
	content {
      title = "Number of Blocked Processes"
      row = 4
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(`mssql.instance.instance.blockedProcessesCount`) FROM Metric timeseries since 1 hour ago FACET entity.name WHERE entity.name LIKE '%${var.sql_cluster1}%' OR entity.name LIKE '%${var.sql_cluster2}%'"
      }
    }
}
	dynamic "widget_billboard" {

 for_each = var.newrelic_platform == "touch" ? [1] : []
 
	content {
      title = "CPS Heartbeat"
      row = 1
      column = 7
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "select count('Polls') As 'Polls in the last 5 minutes' from Log where customer ='${var.newrelic_customer}' and environment = 'prd' and (message like '%INFO  Workflow Case Polling Service : Checking for future targeted date cases%' or message like '%INFO  Workflow Schedule Polling Service : Checking for due schedules%') since 5 minutes ago FACET hostname"
      }
	  critical = 1
	  warning = 3
    }
}

}
  
  
  page {
    name = "${var.eq_application} Alert Summary"

    widget_billboard {
      title = "Current Alerts Open"
      row = 1
      column = 1
	  width = 1
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentId) AS incidents FROM NrAiIncident WHERE policyName IN ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' WHERE event = 'open' since 1 day ago"
      }
	  critical = 5
    }
	
    widget_line {
      title = "Alert history"
      row = 1
      column = 2
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentId) FROM NrAiIncident WHERE policyName IN ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' AND event = 'open' since 1 day ago timeseries"
      }
    }	
	
    widget_pie {
      title = "Incidents by Policy"
      row = 1
      column = 6
	  width = 3
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentId) FROM NrAiIncident WHERE policyName IN ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' FACET policyName SINCE 1 day ago"
			
      }
    }		
    widget_pie {
      title = "Incidents by Condition"
      row = 1
      column = 9
	  width = 3
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentId) FROM NrAiIncident WHERE policyName IN ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' FACET conditionName SINCE 1 day ago"
		
      }
    }	
	
    widget_billboard {
      title = "Average Time to Close"
      row = 1
      column = 12
	  width = 1
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(durationSeconds/60/60) AS 'Hours' FROM NrAiIncident  where `event` in ('close') and policyName in ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' SINCE 1 day ago"
      }
    }
	
    widget_table {
      title = "Events in the Last Day"
      row = 4
      column = 1
	  width = 8
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(timestamp), latest(conditionName), latest(event), latest(title), latest(policyName), latest(incidentLink) FROM NrAiIncident WHERE policyName in ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' FACET title LIMIT MAX since 1 day ago"
      }
    }

    widget_line {
      title = "Open and Closed Incidents"
      row = 4
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT filter(uniqueCount(incidentId), where `event` = 'open') as 'Open', filter(uniqueCount(incidentId), where `event` = 'close') as 'Closed' FROM NrAiIncident WHERE policyName IN ('${var.newrelic_prdalertpolicy}') OR tags.platform = '${var.newrelic_platform}' AND tags.customer = '${var.newrelic_customer}' SINCE 1 day ago TIMESERIES"
      }
    }
	
}

 dynamic "page" {

	for_each = var.environment
	
	content {
  
    name = page.value

    widget_line {
      title = "Webserver CPU"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM SystemSample FACET hostname WHERE platform = '${var.newrelic_platform}' AND tier LIKE '%web%' AND environment LIKE '%${page.value}%' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }

    widget_line {
      title = "Webserver Memory %"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent) FROM SystemSample  FACET hostname WHERE platform = '${var.newrelic_platform}' AND environment LIKE '%${page.value}%' AND tier LIKE '%web%' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }
	
    widget_line {
      title = "Average Webserver Dynamic RAM"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryTotalBytes) FROM SystemSample  FACET hostname WHERE platform = '${var.newrelic_platform}' AND environment LIKE '%${page.value}%' AND tier LIKE '%web%' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }	

    widget_line {
      title = "Appserver CPU"
      row = 4
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM SystemSample FACET hostname, role WHERE platform = '${var.newrelic_platform}' AND tier LIKE '%application%' AND environment LIKE '%${page.value}%' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }

    widget_line {
      title = "Appserver Memory %"
      row = 4
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent) FROM SystemSample  FACET hostname, role WHERE platform = '${var.newrelic_platform}' AND environment LIKE '%${page.value}%' AND tier LIKE '%application%' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }
	
    widget_line {
      title = "Average Appserver Dynamic RAM"
      row = 4
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryTotalBytes) FROM SystemSample  FACET hostname, role WHERE platform = '${var.newrelic_platform}' AND environment LIKE '%${page.value}%' AND tier LIKE '%application%' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }	

	dynamic "widget_line" {

 for_each = var.sql_cluster == "false" ? [1] : []
 
	content {

      title = "SQL CPU"
      row = 8
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM SystemSample FACET hostname WHERE platform = '${var.newrelic_platform}' AND tier = 'database' AND environment = '${page.value}' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }
	}

	dynamic "widget_line" {

 for_each = var.sql_cluster == "false" ? [1] : []
 
	content {
	
      title = "SQL Memory %"
      row = 8
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent) FROM SystemSample  FACET hostname WHERE platform = '${var.newrelic_platform}' AND environment = '${page.value}' AND tier = 'database' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }
	}

	dynamic "widget_line" {

 for_each = var.sql_cluster == "false" ? [1] : []
 
	content {
	
      title = "Average SQL Load"
      row = 8
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(loadAverageFiveMinute) FROM SystemSample  FACET hostname WHERE platform = '${var.newrelic_platform}' AND environment = '${page.value}' AND tier = 'database' AND customer = '${var.newrelic_customer}' LIMIT 100 TIMESERIES AUTO"
      }
    }	
	}
	}
	}
	
	page {
	
    name = "Hyper-V"

    dynamic "widget_table" {

	for_each = var.hypervhost
	
	content {
  
    title = widget_table.value

	  row = 1
	  column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
	    account_id = 2842696
        query       = "FROM vmcpuhyperv SELECT latest(CPUUsage), latest(AssignedMemory), latest(UpTime) / 86400000 AS 'UP TIME (days)' where hostname = '${widget_table.value}' AND VMName NOT LIKE '%_do_not_start%' AND VMName NOT LIKE '%VirtualFibre' AND VMName NOT LIKE 'USVMDMZ%' AND   State IN (2, 3, 5, 10, 11, 15) FACET VMName, CASES( WHERE State = 2 AS 'OK', WHERE State = 3 AS 'Degraded', WHERE State = 5 AS 'Predictive Failure', WHERE State = 10 AS 'Stopped', WHERE State = 11 AS 'In Service', WHERE State = 15 AS 'Dormant' ) AS Status ORDER BY CPUUsage DESC SINCE 1 hour ago LIMIT MAX"
      }
    }
	}
	
	dynamic "widget_line" {

	for_each = var.hypervhost
	
	content {
  
    title = "# of Virtual Machines on ${widget_line.value}"

	  row = 1
	  column = 5
	  width = 2
	  height = 3
	  
      nrql_query {
	    account_id = 2842696	  
        query       = "FROM vmcpuhyperv SELECT uniqueCount(VMName) AS 'Virtual Machines' where hostname = '${widget_line.value}' AND VMName NOT LIKE '%_do_not_start%' AND VMName NOT LIKE '%VirtualFibre%' AND VMName NOT LIKE 'USVMDMZ%' AND VMName NOT LIKE '%clone' AND VMName NOT LIKE '%DO%' AND State IN (2, 3, 5, 10, 11, 15) TIMESERIES AUTO   LIMIT MAX"
      }
    }
	}
	dynamic "widget_table" {

	for_each = var.hypervhost
	
	content {
  
    title = "${widget_table.value} Stats"

	  row = 1
	  column = 8
	  width = 6
	  height = 3
	  
      nrql_query {
	    account_id = 2842696	  
        query       = "SELECT latest(coreCount), latest(hyperv_logical_processors), latest(hyperv_partitions), latest(hyperv_virtual_processors), latest(instanceType), latest(processorCount) FROM Hyper_V_Hypervisor WHERE hostname = '${widget_table.value}' SINCE 30 MINUTES AGO"
      }
    }
	}	
	}

	dynamic "page" {
 
 for_each = var.sql_cluster == "true" ? [1] : []
	
	content {

    name = "SQL Cluster"

    widget_line {
      title = "CPU"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM SystemSample FACET hostname WHERE hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') LIMIT 100 TIMESERIES AUTO "
      }
    }
	
    widget_line {
      title = "Memory %"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent) FROM SystemSample FACET hostname WHERE hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') LIMIT 100 TIMESERIES AUTO "
      }
    }
	
    widget_line {
      title = "Average Load"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(loadAverageFiveMinute) FROM SystemSample FACET hostname WHERE hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') LIMIT 100 TIMESERIES AUTO "
      }
    }

    widget_stacked_bar {
      title = "CPU Working Hours"
      row = 4
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent as CPU) from SystemSample where hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') and hourOf(timestamp) in ('8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_stacked_bar {
      title = "Memory Working Hours"
      row = 4
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent as Memory) from SystemSample where hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') and hourOf(timestamp) in ('8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_bar {
      title = "Storage"
      row = 4
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(diskUsedPercent) as 'Used %' FROM StorageSample FACET hostname,device WHERE hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') LIMIT MAX "
      }
    }	

    widget_line {
      title = "Lock Waits Per Second"
      row = 7
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(`mssql.instance.stats.lockWaitsPerSecond`) FROM Metric timeseries since 1 hour ago FACET entity.name WHERE entity.name LIKE '%${var.sql_cluster1}%' OR entity.name LIKE '%${var.sql_cluster2}%'"
      }
    }	

    widget_line {
      title = "Number of Blocked Processes"
      row = 7
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(`mssql.instance.instance.blockedProcessesCount`) FROM Metric timeseries since 1 hour ago FACET entity.name WHERE entity.name LIKE '%${var.sql_cluster1}%' OR entity.name LIKE '%${var.sql_cluster2}%'"
      }
    }

    widget_table {
      title = "Process State"
      row = 7
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "FROM ProcessSample SELECT latest(timestamp) FACET hostname, commandName, state WHERE hostname IN ('${var.sql_cluster1}', '${var.sql_cluster2}') AND commandName IN ('Rrp.WindowsService.SSISService.exe', 'sqlservr.exe', 'SQLAGENT.EXE', 'fdlauncher.exe', 'MsDtsSrvr.exe') ORDER BY state DESC"
      }
    }
	}
	}
	dynamic "page" {
 
 for_each = var.fss_cluster == "true" ? [1] : []
	
	content {

    name = "FSS Cluster"

    widget_line {
      title = "CPU"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM SystemSample FACET hostname WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') LIMIT 100 TIMESERIES AUTO "
      }
    }
	
    widget_line {
      title = "Memory %"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent) FROM SystemSample FACET hostname WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') LIMIT 100 TIMESERIES AUTO "
      }
    }
	
    widget_line {
      title = "Average Load"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(loadAverageFiveMinute) FROM SystemSample FACET hostname WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') LIMIT 100 TIMESERIES AUTO "
      }
    }

    widget_stacked_bar {
      title = "CPU Working Hours"
      row = 4
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent as CPU) from SystemSample where hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') and hourOf(timestamp) in ('8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_stacked_bar {
      title = "Memory Working Hours"
      row = 4
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent as Memory) from SystemSample where hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') and hourOf(timestamp) in ('8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_bar {
      title = "Storage"
      row = 4
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(diskUsedPercent) as 'Used %' FROM StorageSample FACET hostname,device WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') LIMIT MAX "
      }
    }	

    widget_stacked_bar {
      title = "CPU Non-Working Hours"
      row = 7
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent as CPU) from SystemSample where hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') and hourOf(timestamp) in ('18:00','19:00','20:00','21:00','22:00','23:00','0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_stacked_bar {
      title = "Memory Non-Working Hours"
      row = 7
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent as Memory) from SystemSample where hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') and hourOf(timestamp) in ('18:00','19:00','20:00','21:00','22:00','23:00','0:00','1:00','2:00','3:00','4:00','5:00','6:00','7:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_table {
      title = "Process State"
      row = 7
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "FROM ProcessSample SELECT latest(timestamp) FACET hostname, commandName, state WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') AND commandName IN ('MonitoringHost.exe', 'lsass.exe', 'rhs.exe') ORDER BY state DESC"
      }
    }	
	
    widget_table {
      title = "Cluster Node State"
      row = 10
      column = 1
	  width = 4
	  height = 2
	  
      nrql_query {
        query       = "FROM clusterNode SELECT latest(timestamp) WHERE name IN ('${var.fss_cluster1}', '${var.fss_cluster2}') FACET name as 'Node', state"
      }
    }	
	
    widget_table {
      title = "Cluster OwnerNode"
      row = 10
      column = 5
	  width = 4
	  height = 2
	  
      nrql_query {
        query       = "FROM clusterResource SELECT latest(timestamp) WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') FACET name, type, ownernode, state"
      }
    }	
		
    widget_table {
      title = "Cluster Disk Free Space (%)"
      row = 10
      column = 9
	  width = 4
	  height = 2
	  
      nrql_query {
        query       = "SELECT latest(`Percent Remaining`) AS 'Free %' FROM clusterDisk  WHERE hostname IN ('${var.fss_cluster1}', '${var.fss_cluster2}') FACET hostname, FileSystemLabel LIMIT MAX ORDER BY `Percent Remaining` ASC"
      }
    }			
		
}
	
	}

	dynamic "page" {
 
 for_each = var.rabbitmq == "true" ? [1] : []
	
	content {

    name = "RabbitMQ Cluster"

    widget_line {
      title = "CPU"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM SystemSample FACET hostname WHERE hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') LIMIT 100 TIMESERIES AUTO "
      }
    }
	
    widget_line {
      title = "Memory %"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent) FROM SystemSample FACET hostname WHERE hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') LIMIT 100 TIMESERIES AUTO "
      }
    }
	
    widget_line {
      title = "Average Load"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(loadAverageFiveMinute) FROM SystemSample FACET hostname WHERE hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') LIMIT 100 TIMESERIES AUTO "
      }
    }

    widget_stacked_bar {
      title = "CPU Working Hours"
      row = 4
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(cpuPercent as CPU) from SystemSample where hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') and hourOf(timestamp) in ('8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_stacked_bar {
      title = "Memory Working Hours"
      row = 4
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(memoryUsedPercent as Memory) from SystemSample where hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') and hourOf(timestamp) in ('8:00','9:00','10:00','11:00','12:00','13:00','14:00','15:00','16:00','17:00','18:00') SINCE 1 week ago LIMIT MAX FACET  weekdayof(timestamp) with timezone 'America/Chicago' TIMESERIES "
      }
    }	

    widget_bar {
      title = "Storage"
      row = 4
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(diskUsedPercent) as 'Used %' FROM StorageSample FACET hostname,device WHERE hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') LIMIT MAX "
      }
    }	

    widget_line {
      title = "Total Messages by Queue"
      row = 7
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "select average(`rabbitmq.queue.totalMessages`) FROM Metric timeseries 10 minutes since 12 hours ago facet host.hostname, entity.name WHERE host.hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}')"
      }
    }	

    widget_line {
      title = "Total Message Throughput by Queue"
      row = 7
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "select average(`rabbitmq.queue.totalMessagesPerSecond`) FROM Metric timeseries 10 minutes since 12 hours ago facet host.hostname, entity.name WHERE host.hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}')"
      }
    }	

    widget_table {
      title = "Process State"
      row = 7
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "FROM ProcessSample SELECT latest(timestamp) FACET hostname, commandName, state WHERE hostname IN ('${var.rabbitmq_node1}', '${var.rabbitmq_node2}') AND commandName IN ('erlsrv.exe') ORDER BY state DESC"
      }
    }	
}
	
	}

	dynamic "page" {
 
 for_each = var.newrelic_customer == "IPS" ? [1] : []
	
	content {
	
    name = "F5 BIG-IP"	
	
    widget_line {
      title = "F5 Pool Connections"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(`f5.pool.connections`) FROM Metric where (entity.name = 'pool:/Common/ltm_pool_prd_hpmo_default' or entity.name = 'pool:/Common/ltm_pool_prd_hpmo_dps') AND reportingEndpoint IN ('TL-BIGIP-01.pga.toplev.com:443') FACET entity.name since 30 minutes ago TIMESERIES"
      }
    }
	
    widget_line {
      title = "F5 Node Connections"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(`f5.node.connections`) FROM Metric FACET entity.name WHERE reportingEndpoint IN ('TL-BIGIP-01.pga.toplev.com:443') and (entity.name NOT LIKE 'node:/Common/IPS-PREPROD0%' AND entity.name !='node:/Common/IPS-REPORTS01' AND entity.name != 'node:/Common/IPS-WEB01-IAB') timeseries limit max"
      }
    }	
	
    widget_line {
      title = "F5 VirtualServer Connections"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(`f5.virtualserver.connections`) FROM Metric FACET entity.name WHERE reportingEndpoint IN ('TL-BIGIP-01.pga.toplev.com:443') TIMESERIES SINCE 30 minutes ago "
      }
    }		
	}
	}

	page {
	
    name = "Service Monitoring"

    dynamic "widget_table" {
	
		for_each = var.services

		content {
	
    title = widget_table.value
    
          column = (((widget_table.key % 3) * 4) + 1)
          width = 4
          row    = (abs(format("%.0f", (widget_table.key / 3))) * 4) + 1
          height  = 4		  
	  
      nrql_query {
        query       = "FROM ProcessSample SELECT latest(timestamp) FACET hostname, commandName, state WHERE platform = '${var.newrelic_platform}' AND processDisplayName = '${widget_table.value}' AND customer = '${var.newrelic_customer}' LIMIT MAX"
      }
    }
	
	}
	}

	dynamic "page" {
 
 for_each = var.newrelic_platform == "outreach" ? [1] : []
	
	content {

    name = "Outreach"

    widget_line {
      title = "Disk Total Utilization %"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(totalUtilizationPercent) FROM StorageSample TIMESERIES FACET hostname, mountPoint WHERE platform = '${var.newrelic_platform}' AND customer = '${var.newrelic_customer}' LIMIT 100 SINCE 60 minutes ago"
      }
    }
	
	widget_line {
      title = "OFServer Thread Count"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(threadCount) FROM ProcessSample WHERE processDisplayName = 'OFServer.exe' AND platform = '${var.newrelic_platform}' AND customer = '${var.newrelic_customer}' TIMESERIES FACET hostname"
      }
    }

	widget_line {
      title = "OFServer - Virtual Bytes"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT latest(memoryVirtualSizeBytes) FROM ProcessSample WHERE processDisplayName = 'OFServer.exe' AND platform = '${var.newrelic_platform}' AND customer = '${var.newrelic_customer}' TIMESERIES FACET hostname"
      }
    }

	widget_table {
      title = "Outreach Windows Application Event Logs"
      row = 4
      column = 1
	  width = 12
	  height = 3
	  
      nrql_query {
        query       = "SELECT hostname, EventID, SourceName, WinEventType, message FROM Log WHERE EventID IN (256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290) AND platform = '${var.newrelic_platform}' AND customer = '${var.newrelic_customer}' LIMIT MAX"
      }
    }

	
	}
	}

	dynamic "page" {
 
 for_each = var.newrelic_platform == "touch" ? [1] : []
	
	content {

    name = "Touch"

    widget_table {
      title = "System Overview by Role"
      row = 1
      column = 1
	  width = 12
	  height = 5
	  
      nrql_query {
        query       = "SELECT uniquecount(hostname) AS 'Hosts', average(cpuPercent) AS 'CPU Average %', max(cpuPercent) AS 'CPU max %', average(memoryUsedPercent) AS 'Memory Average %', max(memoryUsedPercent) AS 'Memory Max %', average(readIoPerSecond) as 'Read IOPS Average', max(readIoPerSecond) as 'Read IOPS Max', average(writeIoPerSecond) as 'Write IOPS Average', max(readIoPerSecond) as 'Write IOPS Max' FROM SystemSample, StorageSample WHERE (customer ='${var.newrelic_customer}' and environment = 'prd') FACET role SINCE 10 minutes ago limit MAX"
      }
    }

    widget_table {
      title = "System Overview by Host"
      row = 6
      column = 1
	  width = 12
	  height = 5
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) AS 'CPU Average %', max(cpuPercent) AS 'CPU max %', average(memoryUsedPercent) AS 'Memory Average %', max(memoryUsedPercent) AS 'Memory Max %', average(readIoPerSecond) as 'Read IOPS Average', max(readIoPerSecond) as 'Read IOPS Max', average(writeIoPerSecond) as 'Write IOPS Average', max(readIoPerSecond) as 'Write IOPS Max' FROM SystemSample, StorageSample WHERE (customer ='${var.newrelic_customer}' and environment = 'prd') FACET hostname, role SINCE 10 minutes ago limit MAX"
      }
    }	
	
	}
	}
	
	dynamic "page" {
 
 for_each = var.newrelic_platform == "touch" ? [1] : []
	
	content {

    name = "Compendia for Touch"

    widget_billboard {
      title = "CPS Heartbeat"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "select count('Polls') As 'Polls in the last 5 minutes' from Log where customer ='${var.newrelic_customer}' and environment = 'prd' and platform = '${var.newrelic_platform}' and role = 'admin-app' OR features LIKE '%cps%' and message like '%INFO  Workflow Case Polling Service : Checking for future targeted date cases%' since 5 minutes ago FACET hostname"
      }
	  critical = 1
	  warning = 3
    }

    widget_table {
      title = "CPS Errors"
      row = 1
      column = 5
	  width = 8
	  height = 3
	  
      nrql_query {
        query       = "select hostname, message from Log where customer ='${var.newrelic_customer}' and environment = 'prd' and platform = '${var.newrelic_platform}' and filePath like '%CaseProcessingService%' and message like '%ERROR%' order by timestamp desc since 1 day ago"
      }
    }	

    widget_line {
      title = "Task Engine Pooled Connections"
      row = 4
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "FROM compendia_custom SELECT latest(NumberOfPooledConnections) where Name LIKE '%cnstaskengineservice%' and customer ='${var.newrelic_customer}' and environment = 'prd' and platform = '${var.newrelic_platform}' and role = 'admapi cnsfts' OR features = 'admapi cnsfts' FACET hostname, Name TIMESERIES 5 minutes since 1 day ago"
      }
    }

    widget_table {
      title = "IPS Messages"
      row = 4
      column = 5
	  width = 8
	  height = 3
	  
      nrql_query {
        query       = "select hostname, message from Log where customer ='${var.newrelic_customer}' and environment = 'prd' and platform = '${var.newrelic_platform}' and filePath like '%InboxProcessingService%' since 1 day ago"
      }
    }	

	
	}
	}
	
	
	
	
	dynamic "page" {
 
 for_each = var.newrelic_customer == "IPS" ? [1] : []
	
	content {

    name = "HMPO"

    widget_billboard {
      title = "Booking Count"
      row = 1
      column = 1
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "FROM Log SELECT latest(Count) WHERE Database = 'IPS-Live-AppointmentBookingsDB' FACET cases(WHERE Description = 'DP' AS 'Digital Premium', WHERE Description = 'FF' AS 'International Face to Face', WHERE Description = 'FT' AS 'Fast Track', WHERE Description = 'IN' AS 'Interview')"
      }
    }
	
    widget_billboard {
      title = "Slots Available"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "FROM Log SELECT latest(Count) WHERE hostname = 'IL3-SQLServer' FACET CASES (WHERE Description = 'DP' AS 'Digital Premium', WHERE Description = 'FF' AS 'International Face to Face', WHERE Description = 'FT' AS 'Fast Track', WHERE Description = 'IN' AS 'Interview', WHERE Description = 'FX' AS 'Flexible')"
      }
    }	

    widget_line {
      title = "Application Requests"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT count(*) AS 'NoAppointmentsRedirect' FROM Log WHERE `uristem` = '/outreach/publicbooking.ofml' AND (`status` = 302 OR `status` = '302') TIMESERIES"
      }
	  nrql_query {
        query       = "SELECT count(*) AS 'AllowedPages' FROM Log WHERE `uristem` = '/outreach/publicbooking.ofml' AND (`status` = 200 OR `status` = '200') AND NOT ((protocolversion = 'HTTP/2.0' AND (scbytes = 4449 OR scbytes = 4448 OR scbytes = 11432)) OR (protocolversion = 'HTTP/1.1' AND (scbytes = 4563 OR scbytes = 11471 OR scbytes = 4572 OR scbytes = 4571))) TIMESERIES"
      }
	  nrql_query {
        query       = "SELECT count(*) AS '503ErrorPages' FROM Log WHERE (`uristem` = '/outreach/publicbooking.ofml' OR (`uristem` LIKE '/DPSWebService/live/api%' AND `uristem` != '/DPSWebService/preprod/api/healthcheck')) AND (`status` = 503 OR `status` = '503' OR `status` = 500) TIMESERIES"
      }	  
	  nrql_query {
        query       = "SELECT count(*) AS 'BusyPages' FROM Log WHERE `uristem` = '/outreach/publicbooking.ofml' AND (`status` = 200 OR `status` = '200') AND ((protocolversion = 'HTTP/2.0' AND (scbytes = 4449 OR scbytes = 4448 OR scbytes = 11432)) OR (protocolversion = 'HTTP/1.1' AND (scbytes = 4563 OR scbytes = 11471 OR scbytes = 4572 OR scbytes = 4571 OR scbytes = 4573))) TIMESERIES"
      }	  	
	  nrql_query {
        query       = "SELECT count(*) AS 'NoAppointmentsPagesServed' FROM Log WHERE `uristem` = '/messages/AppointmentsAvailability.html' TIMESERIES"
      }	  	
	  nrql_query {
        query       = "SELECT count(*) AS 'DPS' FROM Log WHERE `uristem` LIKE '%/DPSWebService/live/api%' AND `uristem` != '/DPSWebService/live/api/healthcheck' AND (`status` = 200 OR `status` = '200') TIMESERIES"
      }	  	 
    }	
	
    widget_line {
      title = "HMPO Outreach URL Performance timings"
      row = 5
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(durationBlocked + durationConnect + durationDNS + durationWait) as 'First Byte', average(firstPaint) as 'First Paint', average(firstContentfulPaint) as 'First Contentful Paint', average(onPageLoad) as 'Page Load' FROM SyntheticRequest WHERE monitorId = 'd65a8075-083d-4f3a-8a2d-968b311e3813' AND isNavigationRoot is true  TIMESERIES 5 minutes"
      }
    }
	
    widget_line {
      title = "HMPO Outreach URL Network timings"
      row = 5
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT  average(durationBlocked) as 'Block', average(durationConnect) as 'Connect', average(durationDNS) AS 'DNS', average(durationSSL) as 'SSL', average(durationSend) as 'Send', average(durationWait) as 'Wait', average(durationReceive) as 'Receive'  FROM SyntheticRequest WHERE monitorId = 'd65a8075-083d-4f3a-8a2d-968b311e3813' TIMESERIES 5 minutes"
      }
    }
	
    widget_line {
      title = "IIS Logs - Connections"
      row = 5
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT count(*) FROM Log FACET CASES(WHERE message LIKE '%GET /outreach/publicbooking.ofml - 443%' AS 'Fast Track', WHERE message LIKE '%/DPSWebService/live/api/healthcheck%' AS 'Healthcheck', WHERE message LIKE '%/DPSWebService/live/api/availability%' AS 'Digital Premium', WHERE message LIKE '%/contactcentrebookings.ofml%' AS 'ContactCentre', WHERE message LIKE '%/bookingadminconsole.ofml%' AS 'HMPO') TIMESERIES "
      }
    }	
	
	widget_table {
      title = "Outreach OFServerID Validation"
      row = 9
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "FROM SyntheticCheck SELECT latest(custom.cookieValue) WHERE monitorName LIKE '%EQTL-HMPO_Live0%' FACET monitorName"
      }
    }	
	
	
	}
	}


	dynamic "page" {
 
 for_each = var.newrelic_customer == "fcdo" ? [1] : []
	
	content {

    name = "FCDO"

    widget_line {
      title = "FCDO Consular Booking URL Performance timings"
      row = 1
      column = 1
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "SELECT average(durationBlocked + durationConnect + durationDNS + durationWait) as 'First Byte', average(firstPaint) as 'First Paint', average(firstContentfulPaint) as 'First Contentful Paint', average(onPageLoad) as 'Page Load' FROM SyntheticRequest WHERE monitorId = 'e865dd43-849b-4da0-94cd-d4de3ae7e690' AND isNavigationRoot is true TIMESERIES 5 minutes"
      }
    }
	
    widget_line {
      title = "FCDO Consular Booking URL Network timings"
      row = 1
      column = 5
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "SELECT average(durationBlocked) as 'Block', average(durationConnect) as 'Connect', average(durationDNS) AS 'DNS', average(durationSSL) as 'SSL', average(durationSend) as 'Send', average(durationWait) as 'Wait', average(durationReceive) as 'Receive' FROM SyntheticRequest WHERE monitorId = 'e865dd43-849b-4da0-94cd-d4de3ae7e690' TIMESERIES 5 minutes"
      }
    }	
	
    widget_line {
      title = "Bookings API"
      row = 1
      column = 9
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "SELECT average(cpuPercent) FROM ProcessSample TIMESERIES FACET hostname, processDisplayName WHERE (customer = 'fcdo' AND processDisplayName='EQ.Toplevel.AppointmentBookingSystem.BookingAPI.exe') LIMIT 1000 SINCE 30 minutes ago"
      }
    }		
}
}

	dynamic "page" {
 
 for_each = var.synthetic == "true" ? [1] : []
	
	content {

    name = "Synthetic"

    widget_table {
      title = "Success Rate (24 hours)"
      row = 1
      column = 1
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT percentage(count(*), where result = 'SUCCESS') as 'Availability%' FROM SyntheticCheck WHERE monitorName LIKE '%${var.synthetic_name}%' SINCE 24 hours ago FACET monitorName "
      }
    }
	
    widget_table {
      title = "Average duration (ms) by Location"
      row = 1
      column = 5
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT average(durationDNS) as 'DNS', average(durationSSL) as 'SSL', average(durationConnect) as 'Connect', average(durationSend) as 'Send', average(durationWait) as 'Wait', average(durationBlocked) as 'Blocked', average(durationReceive) as 'Receive', average(duration) as 'Duration' from SyntheticRequest WHERE monitorName LIKE '%${var.synthetic_name}%' since today facet locationLabel"
      }
    }
	
    widget_pie {
      title = "Response codes"
      row = 1
      column = 9
	  width = 4
	  height = 3
	  
      nrql_query {
        query       = "SELECT count(*) FROM SyntheticRequest WHERE monitorName LIKE '%${var.synthetic_name}%' SINCE 24 hours ago FACET responseCode limit 100"
      }
    }

}
}

	dynamic "page" {
 
 for_each = var.apm == "true" ? [1] : []
	
	content {

    name = "APM"

    widget_table {
      title = "Web Transactions"
      row = 1
      column = 1
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "FROM Metric SELECT (count(apm.service.error.count) / count(apm.service.transaction.duration) * 100) as 'Error Rate [%]', rate(count(apm.service.transaction.duration), 1 minute) as 'Web throughput', average(apm.service.transaction.duration * 1000) AS 'Response time' WHERE (appName LIKE '%${var.apm_name}%') AND (transactionType = 'Web') LIMIT MAX SINCE 1800 seconds AGO  FACET appName"
      }
    }
	
    widget_table {
      title = "APDEX"
      row = 1
      column = 5
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "FROM Metric SELECT apdex(apm.service.apdex) as 'App server', apdex(apm.service.apdex.user) as 'End user' WHERE (appName LIKE '%${var.apm_name}%') LIMIT MAX SINCE 1800 seconds AGO FACET appName"
      }
    }

    widget_table {
      title = "Anomaly duration (seconds)"
      row = 1
      column = 9
	  width = 4
	  height = 4
	  
      nrql_query {
        query       = "FROM NrAiIncident SELECT entity.name, durationSeconds WHERE event = 'close' WHERE entity.name LIKE '%${var.apm_name}%'"
      }
    }

    widget_billboard {
      title = "Total APM Anomalies"
      row = 5
      column = 1
	  width = 1
	  height = 3
	  
      nrql_query {
        query       = "SELECT uniqueCount(incidentId) AS anomalies FROM NrAiIncident WHERE evaluationType = 'anomaly' AND event = 'open' AND entity.name LIKE '%${var.apm_name}%' SINCE 1 day ago"
      }
	  warning = 5
	  critical = 10
    }	

}
}



	}	
