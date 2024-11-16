function Show-Menu {
    param (
        [string]$Title = 'Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "1: Crear grupo de usuarios"
    Write-Host "2: Asignar grupo a usuario"
    Write-Host "3: Listar usuarios con sus grupos"
    Write-Host "4: Listar grupos"
    Write-Host "5: Eliminar usuario de un grupo"
    Write-Host "0: Salir"
}

# Función para crear un nuevo grupo
function New-Grupo {
    param (
        [string]$GroupName
    )
    if (-not (Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue)) {
        New-LocalGroup -Name $GroupName
        Write-Host "Grupo '$GroupName' creado exitosamente."
    } else {
        Write-Host "El grupo '$GroupName' ya existe."
    }
}

# Función para listar usuarios con sus grupos
function Get-Usuarios {
    # Obtiene todos los grupos y sus miembros, almacenados en un diccionario
    $groupMembers = @{}
    foreach ($group in Get-LocalGroup) {
        $groupMembers[$group.Name] = Get-LocalGroupMember -Group $group.Name -ErrorAction SilentlyContinue
    }

    # Inicializa una lista para los resultados
    $userList = @()

    # Obtiene cada usuario y determina sus grupos
    foreach ($user in Get-LocalUser) {
        $userGroups = @()
        
        # Compara el usuario con cada grupo utilizando una coincidencia exacta de nombre
        foreach ($group in $groupMembers.Keys) {
            $members = $groupMembers[$group] | Where-Object { $_.ObjectClass -eq "User" }
            if ($members | Where-Object { $_.Name -match "$($env:COMPUTERNAME)\\$($user.Name)" }) {
                $userGroups += $group
            }
        }

        # Agrega el usuario y sus grupos a la lista
        $userList += [PSCustomObject]@{
            Name   = $user.Name
            Grupos = if ($userGroups) { $userGroups -join ", " } else { "Ninguno" }
        }
    }

    # Muestra los resultados en una tabla
    $userList | Format-Table -AutoSize
}

# Función para listar todos los grupos
function Get-Grupos {
    Get-LocalGroup | Format-Table Name -AutoSize
}

# Función para asignar un grupo a un usuario
function Add-Group-to-User {
    param (
        [string]$UserName,
        [string]$GroupName
    )
    if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
        if (Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue) {
            Add-LocalGroupMember -Group $GroupName -Member $UserName
            Write-Host "Usuario '$UserName' asignado al grupo '$GroupName' exitosamente."
        } else {
            Write-Host "El grupo '$GroupName' no existe."
        }
    } else {
        Write-Host "El usuario '$UserName' no existe."
    }
}

# Función para eliminar un usuario de un grupo
function Remove-User-from-Group {
    param (
        [string]$UserName,
        [string]$GroupName
    )
    if (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue) {
        if (Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue) {
            Remove-LocalGroupMember -Group $GroupName -Member $UserName
            Write-Host "Usuario '$UserName' eliminado del grupo '$GroupName' exitosamente."
        } else {
            Write-Host "El grupo '$GroupName' no existe."
        }
    } else {
        Write-Host "El usuario '$UserName' no existe."
    }
}

# Función principal que muestra el menú y maneja las opciones seleccionadas
function Main {
    do {
        Show-Menu
        $choice = Read-Host "Seleccione una opcion"
        switch ($choice) {
            1 {
                $groupName = Read-Host "Ingrese el nombre del grupo a crear"
                New-Grupo -GroupName $groupName
            }
            2 {
                Get-Usuarios
                $userName = Read-Host "Ingrese el nombre del usuario"
                $groups = Get-LocalGroup | Select-Object -ExpandProperty Name
                Write-Host "Grupos disponibles:"
                $groups | Format-Table -AutoSize
                $groupName = Read-Host "Ingrese el nombre del grupo a asignar"
                Add-Group-to-User -UserName $userName -GroupName $groupName
            }
            3 {
                Get-Usuarios
            }
            4 {
                Get-Grupos
            }
            5 {
                Get-Usuarios
                $userName = Read-Host "Ingrese el nombre del usuario"
                $groups = Get-LocalGroup | Select-Object -ExpandProperty Name
                Write-Host "Grupos disponibles:"
                $groups | Format-Table -AutoSize
                $groupName = Read-Host "Ingrese el nombre del grupo del cual eliminar al usuario"
                Remove-User-from-Group -UserName $userName -GroupName $groupName
            }
            0 {
                Write-Host "Saliendo..."
            }
            default {
                Write-Host "Opción no válida. Intente de nuevo."
            }
        }
        Pause
    } while ($choice -ne 0)
}

Main