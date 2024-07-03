class ProjectTemplateInfo {
    projectType: number;
    name: string;
    description: string;
    templateId: number;
    properties: object;

    constructor(projectType, name, description, templateId, properties) {
        this.projectType = projectType;
        this.name = name;
        this.description = description;
        this.templateId = templateId;
        this.properties = properties;
    }

}

class ProjectTemplateProperty {
    inputType: string;
    key: string;
    label: string;
    order: number;
    required: boolean;

    constructor(inputType, key, label, order, required) {
       this.inputType = inputType;
       this.key = key;
       this.label = label;
       this.order = order;
       this.required = required;
    }
}

export {
    ProjectTemplateInfo,
    ProjectTemplateProperty
}
