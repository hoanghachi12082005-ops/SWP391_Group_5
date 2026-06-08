/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package employee.model;

/**
 *
 * @author PCQN
 */
public class Role {

    private int roleID;
    private String name;
    private String description;

    public Role() {
    }

    public Role(int roleID, String name, String description) {
        this.roleID = roleID;
        this.name = name;
        this.description = description;
    }

    public int getRoleID() {
        return roleID;
    }

    public void setRoleID(int roleID) {
        this.roleID = roleID;
    }

    // Alias để nếu code gọi getRoleId/setRoleId vẫn chạy được
    public int getRoleId() {
        return roleID;
    }

    public void setRoleId(int roleID) {
        this.roleID = roleID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
