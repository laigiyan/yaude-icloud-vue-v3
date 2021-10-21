<template>
  <a-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="關閉">
    <a-form ref="form" :model="model" >
      <a-row>
        <a-col :span="24" >
          <a-form-model-item label="專案名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectName">
            <a-select v-model="model.projectName" placeholder="請選擇專案"  :disabled="true">
              <a-select-option v-for="project in projects":value="project.text"  >{{project.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="diskName">
            <a-input v-model="model.diskName" placeholder="請輸入名稱"  :disabled="true"></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
            <a-input v-model="model.represent" placeholder="請輸入描述" :disabled="true" ></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="大小" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="size">
            <a-input v-model="model.size" placeholder="請輸入大小"  ></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="類型" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="type">
            <a-select v-model="model.type"  placeholder="請選擇類型" >
              <a-select-option v-for="type in types":value="type.value" >{{type.text}}</a-select-option>
            </a-select>

          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="來源" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="source">
            <j-dict-select-tag type="list" v-model="model.source" dictCode="disk_source" @change="getsource(model.source)" placeholder="請選擇來源"  />
          </a-form-model-item>
        </a-col>
        <a-col :span="24" v-show="showSource">
          <a-form-model-item label="來源id" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="sourceId">
            <a-select v-model="model.sourceId"  placeholder="請選擇" >
              <a-select-option v-for="types in sourcetype":value="types.value" >{{types.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="合約日期啟" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
            <j-date v-model="model.startTime" placeholder="請選擇開始時間" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="合約日期止" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
            <j-date v-model="model.endTime" placeholder="請選擇終止時間" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="是否加密" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="bootable">
            <j-dict-select-tag type="list" v-model="model.bootable" dictCode="bootable" placeholder="請選擇是否加密" />
          </a-form-model-item>
        </a-col>
      </a-row>
    </a-form>
  </a-modal>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  export default {
    name: 'OsDiskAdjustModal',
    components: {
    },

    data () {
      return {
        model:{
        },
        form: this.$form.createForm(this),
        title:'',
        width:800,
        visible: false,
        disableSubmit: false,
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {

        },

        url: {
          adjust: "/os/osApplyDisk/adjust",
          getType: "/os/osApplyDisk/getType",
          getImg: "/os/osApplyDisk/getImg",
          getVolume: "/os/osApplyDisk/getVolume",
          getSnapshot: "/os/osApplyDisk/getSnapshot",
          getProject: "/os/osApply/getProject",
        },
        projects:[],
        types:[],
        sourcetype:[],
        showSource: false
      }
    },
    created () {

    },
    methods: {
      adjust (record) {
        this.form.resetFields();
        this.model = Object.assign({}, record);
        this.visible = true;
        this.getType(this.model);
        this.getProjects(this.model);
      },
      handleOk () {
        let that = this;
        let projectId = "";
        let method = 'post';
        let httpurl=this.url.adjust;
        that.projects.forEach((r)=>{
          if(r.text==that.model.projectName){
            that.projectId = r.value;
          }
        })
        let formData={
          projectName: this.model.projectName,
          projectId: this.projectId,
          diskName: this.model.diskName,
          options: "2",
          represent: this.model.represent,
          size: this.model.size,
          type: this.model.type,
          source: this.model.source,
          boostatus: "1",
          startTime: this.model.startTime,
          endTime: this.model.endTime,
          bootable: this.model.bootable,
        }
        httpAction(httpurl,formData,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
          that.close();
        })
      },
      //獲取捲來源
      getsource(source){
        const that = this;
        that.sourcetype = [];
        that.showSource=false;
        if(source=="1"){//映像檔
          that.showSource=true
          let method = "post";
          let httpurl = this.url.getImg;
          httpAction(httpurl,this.model,method).then((res)=>{
            if(res.success){
              const result = res.result
              result.forEach((r)=>{
                this.sourcetype.push({
                  value:r.imgId,
                  text:r.imgName
                })
              })
            }
          })
        }else if(source=="2"){//快照
          that.showSource=true
          let method = "post";
          let httpurl = this.url.getSnapshot;
          httpAction(httpurl,this.model,method).then((res)=>{
            if(res.success){
              const result = res.result
              result.forEach((r)=>{
                this.sourcetype.push({
                  value:r.snapshotId,
                  text:r.snapshotName
                })
              })
            }
          })
        }else if(source=="3"){//卷
          that.showSource=true
          let method = "post";
          let httpurl = this.url.getVolume;
          httpAction(httpurl,this.model,method).then((res)=>{
            if(res.success){
              const result = res.result
              result.forEach((r)=>{
                this.sourcetype.push({
                  value:r.volumeId,
                  text:r.volumeName
                })
              })
            }
          })
        }
      },
      getProjects(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getProject;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },
      getType(record){
        this.types=[];
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getType;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.types.push({
                value:r.type,
                text:r.type
              })
            })
          }
        })
      },
      close () {
        this.$emit('close');
        this.visible = false;
      },


      submitCallback(){
        this.$emit('ok');
        this.visible = false;
      },
      handleCancel () {
        this.close()
      }
    }
  }
</script>