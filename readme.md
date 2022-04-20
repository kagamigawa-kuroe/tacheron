# Tacheron/Tacherontab

---

> The purpose of this script is to implement a timing function similar to cron in linux system.
>
> There are two main implemented commands: **`tacheron`** and **`tacherontab`**.
>
> - **`tacheron`**: 
>
>   **tacheron** is a daemon for executing certain tasks (including ordinary commands and scripts) regularly. When the script is running in the background, if it detects that there is a task (who has been written in the form of a file) that needs to be executed in the corresponding directory (`/etc/tacheron/USERNAME`), the task will be executed automatically.
>
>   When the `tacheron` is been executed, it will check the user of system now, and doing all the timing tasks in the directory corresponding.
>
> - **`tacherontab`**:
>
>   The **tachrontab** command is used to add timed tasks. Different users have their own folders in the directory `/etc/tacheron/`. The **tacherontab** command will add new files to the folder who will be read and executed by the **tachron** process.
>
>   Ordinary users can only add users in their own folders, and the tacheron command run by ordinary users can only read tasks in their own folders, while root users can add new tasks in anyone's directory.
>
> Besides, all the tasks who has been executed will be recorded in log file `/var/log/tacheron`, and  the format of task is also same with command **cron** : `mm hh jj MMM JJJ task`
>
>  ┌───────────── minute (0 - 59)
>
>  │ ┌───────────── hour (0 - 23)
>
>  │ │ ┌───────────── day of the month (1 - 31)
>
>  │ │ │ ┌───────────── month (1 - 12)
>
>  │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
>
>  │ │ │ │ │                                   7 is also Sunday on some systems)
>
>  │ │ │ │ │
>
>  │ │ │ │ │
>
>  \* * * * * <command to execute>




