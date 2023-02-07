module creator.viewport.common.mesheditor.impl;

import creator.viewport.common.mesheditor.tools;
import creator.viewport.common.mesheditor.base;
import i18n;
import creator.viewport;
import creator.viewport.common;
import creator.viewport.common.mesh;
import creator.viewport.common.spline;
import creator.core.input;
import creator.core.actionstack;
import creator.actions;
import creator.ext;
import creator.widgets;
import creator;
import inochi2d;
import inochi2d.core.dbg;
import bindbc.opengl;
import bindbc.imgui;
import std.algorithm.mutation;
import std.algorithm.searching;
import std.stdio;

class IncMeshEditorOneImpl(T) : IncMeshEditorOne {
protected:
    T target;

    Tool[VertexToolMode] tools;

public:
    this(bool deformOnly) {
        super(deformOnly);
        tools[VertexToolMode.Points] = new PointTool;
        tools[VertexToolMode.Connect] = new ConnectTool;
        tools[VertexToolMode.PathDeform] = new PathDeformTool;
    }

    override
    Node getTarget() {
        return target;
    }

    override
    void setTarget(Node target) {
        this.target = cast(T)(target);
    }

    override
    CatmullSpline getPath() {
        auto pathTool = cast(PathDeformTool)(tools[VertexToolMode.PathDeform]);
        return pathTool.path;
    }

    override
    void setPath(CatmullSpline path) {
        auto pathTool = cast(PathDeformTool)(tools[VertexToolMode.PathDeform]);
        pathTool.path = path;
    }

    override
    bool update(ImGuiIO* io, Camera camera) {
        bool changed = false;
        if (toolMode in tools) {
            tools[toolMode].update(io, this, changed);
        } else {
            assert(0);
        }

        if (isSelecting) {
            newSelected = getInRect(selectOrigin, mousePos);
            mutateSelection = io.KeyShift;
            invertSelection = io.KeyCtrl;
        }

        return updateChanged(changed);
    }

    override
    void viewportTools(VertexToolMode mode) {
        switch (mode) {
        case VertexToolMode.Points:
            setToolMode(VertexToolMode.Points);
            setPath(null);
            refreshMesh();
            break;
        case VertexToolMode.Connect:
            setToolMode(VertexToolMode.Connect);
            setPath(null);
            refreshMesh();
            break;
        case VertexToolMode.PathDeform:
            import std.stdio;
            setToolMode(VertexToolMode.PathDeform);
            setPath(new CatmullSpline);
            deforming = false;
            refreshMesh();
            break;
        default:       
        }
    }

    override
    void setToolMode(VertexToolMode toolMode) {
        if (toolMode in tools) {
            this.toolMode = toolMode;
            tools[toolMode].setToolMode(toolMode, this);
        }
    }

}